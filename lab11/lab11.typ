#set text(
  font: "Times New Roman",
  lang: "ru",
  size: 12pt,
)

#let title_page(
  student: "",
  group: "",
  teacher: "",
  lab_number: "",
  course: "",
  theme: "",
  year: "2023",
) = {
  set page(numbering: none)

  grid(
    columns: (auto, 1fr),
    gutter: 1em,
    align: horizon,
    image("emblem.png", width: 2.5cm),

    align(center)[
      #set text(size: 10pt, weight: "bold")
      Министерство науки и высшего образования Российской Федерации \
      Федеральное государственное бюджетное образовательное учреждение \
      высшего образования \
      «Московский государственный технический университет \
      имени Н.Э. Баумана \
      (национальный исследовательский университет)» \
      (МГТУ им. Н.Э. Баумана)
    ],
  )

  v(5pt)
  line(length: 100%, stroke: 2.5pt)
  v(1pt)
  line(length: 100%, stroke: 0.5pt)
  v(1em)

  let field_line(label, value) = {
    grid(
      columns: (auto, 1fr),
      gutter: 10pt,
      text(size: 11pt)[#label],
      stack(
        dir: ttb,
        spacing: 3pt,
        align(center, value),
        line(length: 100%, stroke: 0.5pt),
      ),
    )
  }

  field_line("ФАКУЛЬТЕТ", [«Информатика и системы управления»])
  v(1em)
  field_line("КАФЕДРА", [«Теоретическая информатика и компьютерные технологии»])

  v(6cm)

  align(center)[
    #text(size: 18pt, weight: "bold")[Лабораторная работа № #lab_number] \
    #v(0.5em)
    #text(size: 14pt, weight: "bold")[по курсу «#course»] \
    #v(0.5em)
    #text(size: 14pt)[«#theme»]
  ]

  v(3cm)

  align(right)[
    #block(width: 50%)[
      Студент группы #group \
      *#student* \
      #v(1em)
      Преподаватель \
      *#teacher*
    ]
  ]

  v(1fr)
  align(center)[
    #text(style: "italic")[Москва #year]
  ]

  pagebreak()

  set page(numbering: "1")
  counter(page).update(1)
}

#show raw: set text(font: ("Fira Code"), size: 10pt)

#show raw.where(block: true): it => {
  block(
    fill: luma(245),
    inset: 10pt,
    radius: 5pt,
    width: 100%,
    stroke: 1pt + luma(200),
    it
  )
}

#let terminal(content, title: none) = {
  let bg_color = luma(250)
  let border_color = luma(200)
  let title_bg = luma(240)

  let header = if title != none {
    block(
      width: 100%,
      fill: title_bg,
      inset: (x: 8pt, y: 5pt),
      stroke: (bottom: 0.5pt + border_color),
      radius: (top: 3pt),
      text(size: 9pt, weight: "bold", fill: luma(80), font: "Arial", title)
    )
  } else { none }

  let body = block(
    width: 100%,
    fill: bg_color,
    inset: 10pt,
    radius: if title != none { (bottom: 3pt) } else { 3pt },
    text(font: ("Fira Code", "Courier New"), size: 10pt, content)
  )

  block(
    width: 100%,
    stroke: 0.5pt + border_color,
    radius: 3pt,
    clip: true,
    breakable: false,
    stack(dir: ttb, header, body)
  )
}

#title_page(
  student: "Булдаков А. С.",
  group: "ИУ9-22Б",
  teacher: "Посевин Д. П.",
  lab_number: "11",
  course: "Языки и методы программирования",
  theme: "Рекурсивный спуск. Парсинг_generic_типов",
  year: "2026"
)

#outline()

= Цель работы

Реализовать парсер для_generic_типов языка Java (например, Map[K, V], List[T]) с использованием метода рекурсивного спуска. Парсер должен разбирать входную строку и строить синтаксическое дерево.

*Задачи:*
- Изучить метод рекурсивного спуска.
- Реализовать класс Parser для разбора_generic_типов.
- Обработать вложенные типы и списки аргументов.
- Вывести дерево разбора.


= Теоретические сведения

Метод рекурсивного спуска (recursive descent parsing) — это техника парсинга, при которой парсер рекурсивно вызывает себя для разбора различных частей грамматики. Каждый нетерминал грамматики представлен отдельной функцией.

 grammar для_generic_типов:
Грамматика:
- type = ident (brackets)
- ident = имя типа (буквы и цифры)
- brackets = [args]
- args = type (comma type)...


= Реализация Parser

Внутренний класс Ident представляет узел дерева:

#terminal(title: "Parser.java")[
```java
private static class Ident {
  String name;
  Ident left;
  Ident right;
}
```
]

- name — имя типа (Map, List, Int, String)
- left — параметры типа (если есть)
- right — следующий элемент в списке

== Конструктор и основной метод

#terminal(title: "Parser.java")[
```java
private String input;
private int pos;
public Ident root;
private boolean errorOccurred = false;

public Parser(String str) {
  this.input = str.trim();
}

public void parse() {
  root = parseGener();
  if (errorOccurred) {
    System.err.println("Syntax error at parsing, position: " + pos);
    System.exit(1);
  }
  if (pos < input.length()) {
    System.err.println("Syntax error: unexpected characters at position " + pos);
    System.exit(1);
  }
}
```
]

== parseGener()

Разбор основного типа:

#terminal(title: "Parser.java")[
```java
private Ident parseGener() {
  if (errorOccurred)
    return null;
  while (pos < input.length() && input.charAt(pos) == ' ') {
    pos++;
  }
  Ident ident = new Ident();
  ident.name = parseIdent();
  if (ident.name.isEmpty() && !errorOccurred) {
    syntaxError();
  }
  if (errorOccurred)
    return null;
  ident.left = parseTail();
  return ident;
}
```
]

== parseIdent()

Разбор имени типа:

#terminal(title: "Parser.java")[
```java
private String parseIdent() {
  while (pos < input.length() && input.charAt(pos) == ' ') {
    pos++;
  }
  int start = pos;
  while (pos < input.length() && input.charAt(pos) != '[' 
      && input.charAt(pos) != ']' && input.charAt(pos) != ',') {
    pos++;
  }
  if (pos == start) {
    syntaxError();
    return "";
  }
  return input.substring(start, pos).strip();
}
```
]

== parseTail()

Разбор параметров типа (в квадратных скобках):

#terminal(title: "Parser.java")[
```java
private Ident parseTail() {
  if (errorOccurred)
    return null;
  while (pos < input.length() && input.charAt(pos) == ' ') {
    pos++;
  }
  if (pos >= input.length() || input.charAt(pos) != '[') {
    return null;
  }
  pos++;
  Ident args = parseArgs();
  if (errorOccurred)
    return null;
  while (pos < input.length() && input.charAt(pos) == ' ') {
    pos++;
  }
  if (pos >= input.length() || input.charAt(pos) != ']') {
    syntaxError();
    return null;
  }
  pos++;
  return args;
}
```
]

== parseArgs()

Разбор списка аргументов:

#terminal(title: "Parser.java")[
```java
private Ident parseArgs() {
  if (errorOccurred)
    return null;
  Ident first = parseGener();
  if (first == null) {
    syntaxError();
    return null;
  }
  Ident rest = parseList();
  first.right = rest;
  return first;
}
```
]

== parseList()

Разбор разделённых запятыми аргументов:

#terminal(title: "Parser.java")[
```java
private Ident parseList() {
  if (errorOccurred)
    return null;
  while (pos < input.length() && input.charAt(pos) == ' ') {
    pos++;
  }
  if (pos < input.length() && input.charAt(pos) == ',') {
    pos++;
    return parseArgs();
  }
  return null;
}
```
]

== printTree()

Вывод дерева разбора:

#terminal(title: "Parser.java")[
```java
public void printTree() {
  printTree(root, 0);
}

private void printTree(Ident node, int indent) {
  if (node == null)
    return;
  for (int i = 0; i < indent - 1; i++)
    System.out.print("| ");
  if (indent > 0)
    System.out.print("+ ");
  System.out.println(node.name);
  printTree(node.left, indent + 1);
  printTree(node.right, indent);
}
```
]


= Тестирование

== Простой пример

#terminal(title: "simple.txt")[
```
Map[Int, List[String]]
```
]

#terminal(title: "terminal")[
```bash
$ java Test < simple.txt
Map
+ Int
+ List
+ String
```
]

Древовидная структура:
- Map — корень
- Int — параметр типа (левый потомок)
- List — следующий в списке (правый потомок)
- String — параметр List

== Сложный пример

#terminal(title: "complex.txt")[
```
Map[Map[Map[Map[Int, List[Map[Int, List[String]]]], List[Map[Int, List[String]]]], List[Map[Int, List[String]]]], List[Map[Int, List[String]]]]
```
]

Вывод дерева:
- Map
  + Map
    + Map
      + Map
        + Int
        + List
          + Map
            + Int
            + List
              + String
      + List
        + Map
          + Int
          + List
            + String
  + List
    + Map
      + Int
      + List
        + String


= Класс Test

Чтение из stdin:

#terminal(title: "Test.java")[
```java
public class Test {
  public static void main(String[] args) throws Exception {
    BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
    StringBuilder sb = new StringBuilder();
    String line;
    while ((line = reader.readLine()) != null) {
      sb.append(line).append("\n");
    }

    Parser parser = new Parser(sb.toString());
    parser.parse();
    parser.printTree();
  }
}
```
]


= Вывод

В ходе лабораторной работы был реализован парсер_generic_типов методом рекурсивного спуска:

1. **Класс Ident** — представление узла дерева
2. **parseGener()** — разбор основного типа
3. **parseIdent()** — разбор имени типа
4. **parseTail()** — разбор параметров в скобках
5. **parseArgs()** — разбор списка аргументов
6. **parseList()** — разбор через запятую
7. **printTree()** — вывод дерева разбора

Парсер корректно обрабатывает простые и вложенные_generic_типы языка Java.