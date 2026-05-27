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

#show raw: set text(font: "Fira Code", size: 10pt)

#show raw.where(block: true): it => {
  block(
    fill: luma(245),
    inset: 10pt,
    radius: 5pt,
    width: 100%,
    stroke: 1pt + luma(200),
    it,
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
      text(size: 9pt, weight: "bold", fill: luma(80), font: "Arial", title),
    )
  } else { none }

  let body = block(
    width: 100%,
    fill: bg_color,
    inset: 10pt,
    radius: if title != none { (bottom: 3pt) } else { 3pt },
    text(font: ("Fira Code", "Courier New"), size: 10pt, content),
  )

  block(
    width: 100%,
    stroke: 0.5pt + border_color,
    radius: 3pt,
    clip: true,
    breakable: false,
    stack(dir: ttb, header, body),
  )
}

#title_page(
  student: "Булдаков А. С.",
  group: "ИУ9-22Б",
  teacher: "Посевин Д. П.",
  lab_number: "5",
  course: "Языки и методы программирования",
  theme: "Stream API в Java",
  year: "2026",
)

#outline()

= Цель работы

Изучить Stream API в Java для функциональной обработки данных. Реализовать классы с использованием потоков для работы со строками и битовыми операциями.

*Задачи:*
- Изучить Stream API и методы stream().
- Реализовать класс StringSet для фильтрации строк.
- Реализовать класс Ints для работы с битовымиmasks.
- Использовать IntStream и OptionalInt.


= Теоретические сведения

Stream API — это мощный инструмент для функциональной обработки коллекций в Java. Основные методы:
- filter() — фильтрация элементов
- map() — преобразование элементов
- flatMap() — преобразование элементов
- forEach() — итерация по элементам
- reduce() — агрегация элементов
- findFirst(), findAny() — поиск элемента


= Задание 1: Класс StringSet

Класс для работы со множеством строк с использованием Stream API.

== Класс StringSet

#terminal(title: "StringSet.java")[
  ```java
  public class StringSet {
    private Set<String> strings;

    public StringSet(Set<String> strings) {
      this.strings = strings;
    }

    public Stream<String> stringStream(String s, int k) {
      return strings.stream()
          .filter(str -> countOccurrences(str, s) == k);
    }

    public OptionalInt findN(String s) {
      if (strings.stream().filter(str -> !str.contains(s)).toList().size() == 0) {
        return strings.stream()
            .mapToInt(String::length)
            .min();
      }
      return strings.stream()
          .filter(str -> !str.contains(s))
          .mapToInt(String::length)
          .max();
    }

    private int countOccurrences(String str, String sub) {
      if (sub.isEmpty() || str.isEmpty()) {
        return 0;
      }
      int count = 0;
      int idx = 0;
      while ((idx = str.indexOf(sub, idx)) != -1) {
        count++;
        idx += sub.length();
      }
      return count;
    }
  }
  ```
]

== Метод countOccurrences()

Метод подсчитывает количество вхождений подстроки в строку:
- Использует indexOf() для поиска каждого вхождения
- Сдвигает индекс на длину подстроки после каждого найденного вхождения

== Тестирование StringSet

#terminal(title: "Test.java")[
  ```java
  public class Test {
    public static void main(String[] args) {
      new StringSet(new HashSet<>(Set.of("a", "aa", "aaa", "b", "ab")))
          .stringStream("a", 1).forEach(System.out::println);
      System.out.println("");
      System.out.println(new StringSet(new HashSet<>(Set.of("a", "aa", "aaa", "bbb", "ab"))).findN("a"));
      System.out.println(new StringSet(new HashSet<>(Set.of("a", "aa", "aaa", "ab"))).findN("a"));
    }
  }
  ```
]

Вывод:
- Строки, содержащие ровно 1 вхождение "a": "b", "ab"
- findN("a") для множества со "bbb" — максимальная длина = 3
- findN("a") для множества без "bbb" — максимальная длина = 2


= Задание 2: Класс Ints (дополнительное)

Класс для работы с битовыми операциями.

== Класс Ints

#terminal(title: "Ints.java")[
  ```java
  public class Ints {
    private List<Integer> ints;

    public Ints(List<Integer> ints) {
      this.ints = ints;
    }

    public IntStream unitPositions() {
      return IntStream.range(0, ints.size())
          .flatMap(j -> IntStream.range(0, 32)
              .filter(i -> (ints.get(j) >> i & 1) == 1)
              .map(i -> 32 * j + i));
    }

    public OptionalInt findX() {
      int mask = ints.stream().reduce(0, (a, b) -> a | b);
      return IntStream.range(0, ints.size())
          .filter(i -> (ints.get(i) | mask) == mask)
          .findFirst();
    }
  }
  ```
]

== Метод unitPositions()

Возвращает позиции установленных битов:
- Внешний цикл: по всем числам (0...size)
- Внутренний цикл: по битам (0...31)
- Фильтр: оставляет только установленные биты (x >> i & 1) == 1
- flatMap: объединяет все позиции в один поток

Формула: позиция = 32 умножить номер_числа плюс номер_бита

== Метод findX()

Находит индекс первого числа, содержащего все биты:
- reduce(0, (a, b) -> a | b) — вычисляет битовую маску всех чисел
- filter: оставляет числа, которые содержат все биты маски
- findFirst: возвращает первый индекс

== Тестирование Ints

#terminal(title: "dop/Test.java")[
  ```java
  public class Test {
    public static void main(String[] args) {
      // [1, 3, 7, 16] в двоичном: [1, 11, 111, 10000]
      new Ints(Arrays.asList(1, 1 + 2, 1 + 2 + 4, 16)).unitPositions()
          .forEach(x -> System.out.println(x));
      // [3, 5, 7, 1] -> mask = 7 (111)
      Ints ints = new Ints(Arrays.asList(3, 5, 7, 1));
      OptionalInt result = ints.findX();
      if (result.isPresent()) {
        System.out.println(result.getAsInt());
      }
    }
  }
  ```
]

Вывод unitPositions():
- 1 = 1 -> позиция 0
- 3 = 1 + 2 -> позиции 0, 1
- 7 = 1 + 2 + 4 -> позиции 0, 1, 2
- 16 = 10000 -> позиция 4 + 32 = 36

Вывод findX():
- mask = 3 | 5 | 7 | 1 = 7 (111 в двоичном)
- Число 3 (011) содержит все биты маски 7 (111)? Да
- Результат: индекс 0


= Вывод

В ходе лабораторной работы были изучены и применены:

1. **Stream API** — функциональный подход к обработке данных в Java
2. **Класс StringSet** — фильтрация строк по количеству вхождений подстроки
3. **Метод findN()** — поиск минимальной или максимальной длины строки
4. **Класс Ints** — работа с битовыми масками
5. **Методы unitPositions() и findX()** — поиск позиций битов и индексов

Stream API позволяет писать лаконичный и выразительный код для обработки коллекций.

