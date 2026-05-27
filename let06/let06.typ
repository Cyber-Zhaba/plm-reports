#set text(
  font: "Times New Roman",
  lang: "ru",
  size: 12pt
)

#let title_page(
  student: "",
  group: "",
  teacher: "",
  lab_number: "",
  course: "",
  theme: "",
  year: "2023"
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
    ]
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
        line(length: 100%, stroke: 0.5pt)
      )
    )
  }

  field_line("ФАКУЛЬТЕТ", [«Информатика и системы управления»])
  v(1em)
  field_line("КАФЕДРА", [«Теоретическая информатика и компьютерные технологии»])

  v(8cm)
  
  align(center)[
    #text(size: 18pt, weight: "bold")[Летучка № #lab_number] \
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
  lab_number: "6",
  course: "Языки и методы программирования",
  theme: "Дженерики в Java. Stack<T>",
  year: "2026"
)

#outline()

= Цель работы

Изучить механизм дженериков (generic types) в Java. Реализовать универсальный класс Stack<T> для работы с различными типами данных. Применить дженерики для создания стека, содержащего объекты различного типа.

*Задачи:*
- Изучить синтаксис дженериков в Java.
- Реализовать универсальный класс Stack<T> с методами push() и pop().
- Создать классы RVector и Scalar для работы с векторами.
- Применить дженерики для хранения различных типов в стеке.


= Теоретические сведения

Дженерики (generics) — это механизм, позволяющий создавать классы и методы, которые работают с различными типами данных, сохраняя при этом безопасность типов во время компиляции.

Основные преимущества дженериков:
- Безопасность типов — ошибки обнаруживаются на этапе компиляции
- Уменьшение дублирования кода — один класс работает с разными типами
- Упрощение кода — не требуется приведение типов

Синтаксис дженериков:
- `class Stack<T>` — параметр типа T
- `Stack<Universe>` — конкретный тип


= Реализация

== Универсальный класс Stack<T>

Класс Stack<T> реализует стек с динамическим расширением:

#terminal(title: "Main.java")[
```java
class Stack<T> {
  private int coutn = 0;
  private Object[] buf = new Object[16];

  public boolean empty() {
    return coutn == 0;
  }

  public void push(T x) {
    if (coutn == buf.length) {
      buf = Arrays.copyOf(buf, buf.length * 2);
    }
    buf[coutn++] = x;
  }

  @SuppressWarnings("unchecked")
  public T pop() {
    if (empty()) {
      throw new RuntimeException("underflow");
    }
    return (T) buf[--coutn];
  }
}
```
]

Методы:
- `empty()` — проверка пустоты стека
- `push(T x)` — добавление элемента с автоматическим расширением
- `pop()` — извлечение элемента

== Класс RVector

Класс для представления радиус-вектора:

#terminal(title: "Main.java")[
```java
class RVector {
  int x, y, z;

  public RVector(int x, int y, int z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}
```
]

== Класс Scalar

Класс для вычисления скалярного произведения векторов:

#terminal(title: "Main.java")[
```java
class Scalar {
  RVector a, b;

  public Scalar(RVector a, RVector b) {
    this.a = a;
    this.b = b;
  }

  public int Evaluate() {
    return a.x * b.x + a.y * b.y + a.z * b.z;
  }
}
```
]

Скалярное произведение: $ a \cdot b = a_x \cdot b_x + a_y \cdot b_y + a_z \cdot b_z $

== Класс Vector

Класс Vector для трёхмерного пространства (из предыдущих работ):

#terminal(title: "Vector.java")[
```java
public class Vector {
  public double x, y, z;

  public Vector(double x, double y, double z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  public Vector add(Vector v) {
    return new Vector(x + v.x, y + v.y, z + v.z);
  }

  public static double dist(Vector a, Vector b) {
    double dx = a.x - b.x;
    double dy = a.y - b.y;
    double dz = a.z - b.z;
    return sqrt(dx * dx + dy * dy + dz * dz);
  }

  public static double dot(Vector a, Vector b) {
    return a.x * b.x + a.y * b.y + a.z * b.z;
  }

  public double length() {
    return dist(new Vector(0, 0, 0), this);
  }
}
```
]

== Классы Body и Universe

Классы для моделирования гравитационного взаимодействия:

#terminal(title: "Body.java")[
```java
public class Body {
  Vector r;
  Vector F;
  double m;
  String name;

  public static int instance_count;
  public static final double G = 6.674e-11;

  public Vector getForceFrom(Body other) {
    double r = Vector.dist(this.r, other.r);
    double amount = G * this.m * other.m / (r * r);
    double dx = other.r.x - this.r.x;
    double dy = other.r.y - this.r.y;
    double dz = other.r.z - this.r.z;
    return new Vector(amount * dx / r, amount * dy / r, amount * dz / r);
  }
}
```
]

#terminal(title: "Universe.java")[
```java
public class Universe {
  Body[] bodies;

  public Universe(int n) {
    bodies = new Body[n];
    for (int i = 0; i < n; i++) {
      bodies[i] = new Body();
    }
  }

  public double getTotalMass() {
    double total = 0;
    for (Body bud : bodies) {
      total += bud.m;
    }
    return total;
  }

  public Vector getResultForce(int idx) {
    Vector v = new Vector(0.0, 0.0, 0.0);
    for (int i = 0; i < bodies.length; i++) {
      if (i == idx)
        continue;
      v = v.add(bodies[idx].getForceFrom(bodies[i]));
    }
    return v;
  }
}
```
]


= Использование дженериков

==Основная программа

#terminal(title: "Main.java")[
```java
public class Main {
  public static double drain(Stack<Universe> s) {
    double totalMass = 0.0;
    while (!s.empty()) {
      for (Body b : s.pop().bodies) {
        totalMass += b.m;
      }
    }
    return totalMass;
  }

  public static void main(String[] args) {
    RVector v1 = new RVector(1, 2, 3);
    RVector v2 = new RVector(4, 5, 6);
    RVector v3 = new RVector(7, 8, 9);
    RVector v4 = new RVector(10, 11, 12);

    Stack<Scalar> stack = new Stack<>();
    stack.push(new Scalar(v1, v2));
    stack.push(new Scalar(v3, v4));

    Scalar s1 = stack.pop();
    Scalar s2 = stack.pop();

    int result = s1.Evaluate() + s2.Evaluate();
    System.out.println(result);

    Stack<Universe> stack2 = new Stack<>();
    stack2.push(new Universe(5));
    stack2.push(new Universe(5));
    System.out.println(drain(stack2));
  }
}
```
]


= Тестирование

== Тест 1: Скалярные произведения

Вычисление скалярных произведений:

- $v_1 \cdot v_2 = 1 \cdot 4 + 2 \cdot 5 + 3 \cdot 6 = 4 + 10 + 18 = 32$
- $v_3 \cdot v_4 = 7 \cdot 10 + 8 \cdot 11 + 9 \cdot 12 = 70 + 88 + 108 = 266$
- Сумма: $32 + 266 = 298$

#terminal(title: "terminal")[
```bash
$ java Main
298
----------------------
[*] Body class loaded
[*] Universe class loaded
[+] new Universe instance created ...
```
]

== Тест 2: Стеки с разными типами

Один и тот же класс Stack<T> используется с разными типами:
- `Stack<Scalar>` — стек скалярных произведений
- `Stack<Universe>` — стек вселенных

#terminal(title: "Main.java")[
```java
public static double drain(Stack<Universe> s) {
  double totalMass = 0.0;
  while (!s.empty()) {
    for (Body b : s.pop().bodies) {
      totalMass += b.m;
    }
  }
  return totalMass;
}
```
]

Результат — суммарная масса всех тел во вселенных:


= Вывод

В ходе лабораторной работы были изучены и применены дженерики в Java:

1. Реализован универсальный класс `Stack<T>` с методами `push()` и `pop()`
2. Класс работает с любым типом данных, сохраняя безопасность типов
3. Продемонстрировано использование одного класса с разными типами:
   - `Stack<Scalar>` — для скалярных произведений
   - `Stack<Universe>` — для объектов Вселенной
4. Динамическое расширение стека при заполнении

Дженерики позволяют создавать универсальный код, который работает с различными типами данных без дублирования.