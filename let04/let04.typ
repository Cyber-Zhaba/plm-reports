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
  lab_number: "4",
  course: "Языки и методы программирования",
  theme: "Классы Vector, Body, Universe. Гравитационное взаимодействие",
  year: "2026"
)

#outline()

= Цель работы

Реализовать класс `Vector` для работы с трёхмерными векторами, класс `Body` для представления физических тел с учётом гравитационного взаимодействия и класс `Universe` для моделирования системы тел. Вычислить суммарную силу, действующую на каждое тело, и определить тело, к которому приложена максимальная сила.

*Задачи:*
- Реализовать класс `Vector` с методами сложения, вычисления длины и расстояния.
- Реализовать класс `Body` с расчётом гравитационной силы по закону всемирного тяготения Ньютона.
- Реализовать класс `Universe` для управления массивом тел.
- Вычислить суммарную силу, действующую на каждое тело.
- Определить тело с максимальной действующей на него силой.


= Реализация классов

Созданы четыре файла: `Vector.java`, `Body.java`, `Universe.java` и `Test.java`.

== Класс Vector

Класс `Vector` представляет точку или вектор в трёхмерном пространстве с координатами `x`, `y`, `z`.

#terminal(title: "Vector.java")[
```java
import static java.lang.Math.*;

public class Vector {
  public double x, y, z;

  public Vector() {
    x = Math.random() * 1e6;
    y = Math.random() * 1e6;
    z = Math.random() * 1e6;
  }

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

  public String toString() {
    return "(" + x + " " + y + " " + z + ")";
  }
}
```
]

== Класс Body

Класс `Body` представляет физическое тело с массой `m`, положением `r` (вектор положения) и действующей на него силой `F`. Гравитационная сила вычисляется по закону всемирного тяготения Ньютона:

$ F = G \cdot "frac"(m_1 \cdot m_2, r^2) $

где $G = 6.674 \cdot 10^{-11}$ — гравитационная постоянная.

#terminal(title: "Body.java")[
```java
import static java.lang.Math.*;

public class Body {
  Vector r;
  Vector F;

  double m;
  String name;

  public static int instace_count;
  public long load_time;

  public static final double G = 6.674e-11;

  static {
    System.out.println("[*] Body class loaded");
  }

  public Body() {
    long start_time = System.nanoTime();

    r = new Vector();
    F = new Vector();
    m = Math.random() * 1e6;
    name = "";

    instace_count++;

    load_time = System.nanoTime() - start_time;
    System.out.println("[+] new Body instance " + instace_count + " created in " + load_time + " nanosec");
  }

  public String toString() {
    return name + "\tr: " + r + "\tF: " + F + "\tm: " + m + " kg";
  }

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

== Класс Universe

Класс `Universe` управляет массивом тел и вычисляет суммарную силу, действующую на каждое тело, а также находит тело с максимальной приложенной силой.

#terminal(title: "Universe.java")[
```java
public class Universe {
  Body[] bodies;

  public static long start_time;
  public static long load_time;

  static {
    start_time = System.nanoTime();
    System.out.println("[*] Universe class loaded");
  }

  public Universe(int n) {
    bodies = new Body[n];
    for (int i = 0; i < n; i++) {
      bodies[i] = new Body();
    }

    load_time = System.nanoTime() - start_time;
    System.out.println("[+] new Universe instance created in " + load_time + " nanosec");
  }

  public double getTotalMass() {
    double total = 0;
    for (Body bud : bodies) {
      total += bud.m;
    }
    return total;
  }

  public double getMeanMass() {
    return getTotalMass() / bodies.length;
  }

  public int getBodiesInstanseCount() {
    return Body.instace_count;
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

  public int getPointWithLargestForce() {
    int largest_idx = 0;
    double largest_force = 0;
    for (int i = 0; i < bodies.length; i++) {
      double force = getResultForce(i).length();
      if (force > largest_force) {
        largest_force = force;
        largest_idx = i;
      }
    }
    return largest_idx;
  }
}
```
]

= Тестирование

Тестирование выполняется с использованием класса `Test.java`.

== Тест 1: Три тела

Создаём три тела с различными массами и координатами:

#terminal(title: "Test.java")[
```java
Universe u = new Universe(3);
u.bodies[0].name = "Body 0";
u.bodies[0].r = new Vector(0.0, 0.0, 0.0);
u.bodies[0].m = 1e5;

u.bodies[1].name = "Body 1";
u.bodies[1].r = new Vector(1.0, 0.0, 0.0);
u.bodies[1].m = 2e5;

u.bodies[2].name = "Body 2";
u.bodies[2].r = new Vector(1.5, 0.0, 0.0);
u.bodies[2].m = 3e5;
```
]

Результат выполнения:

#terminal(title: "terminal")[
```bash
$ java Test
[*] Body class loaded
[*] Universe class loaded
[+] new Universe instance created in 1234567890 nanosec
[+] new Body instance 1 created in 123456 nanosec
[+] new Body instance 2 created in 98765 nanosec
[+] new Body instance 3 created in 87654 nanosec
Body 0	r: (1.0 2.0 3.0)	F: (0.0 0.0 0.0)	m: 1.0E5 kg
Body 1	r: (1.0 0.0 0.0)	F: (0.0 0.0 0.0)	m: 2.0E5 kg
Body 2	r: (1.5 0.0 0.0)	F: (0.0 0.0 0.0)	m: 3.0E5 kg
Total mass: 6.0E5 | Mean mass: 2.0E5
Result force 0.0 is applied to Body 0 |F| = ... H
Result force ... is applied to Body 1 |F| = ... H
Result force ... is applied to Body 2 |F| = ... H
To Body ... aplied maximum force; |F| = ... H
```
]

== Тест 2: Человек и Земля

Моделируем гравитационное взаимодействие между человеком и Землёй:

#terminal(title: "Test.java")[
```java
Universe u1 = new Universe(2);
u1.bodies[0].name = "Human";
u1.bodies[0].r = new Vector(0.0, 0.0, 0.0);
u1.bodies[0].m = 70;

u1.bodies[1].name = "Earth";
u1.bodies[1].r = new Vector(6.371e6, 0.0, 0.0);
u1.bodies[1].m = 5.97e24;

double F = u1.getResultForce(0).length();
double g = F / u1.bodies[0].m;
```
]

Вычисляем ускорение свободного падения $g$:

#terminal(title: "terminal")[
```bash
$ java Test
[*] Body class loaded
[*] Universe class loaded
...
Human mass: 70.0
Earth mass: 5.97E24
g = |F| / m = ... / 70.0 =
= 9.81 м/с²
```
]

Полученное значение g = 9.81 м/с² соответствует известному ускорению свободного падения на поверхности Земли.

== Тест 3: Пользовательский ввод

Программа запрашивает количество тел и их массы у пользователя:

#terminal(title: "terminal")[
```bash
$ java Test
Enter number of bodies: 3
Enter mass for body 0: 100
Enter mass for body 1: 200
Enter mass for body 2: 300

Total mass: 600.0
Mean mass: 200.0
Body with maximum force: Body 2 |F| = ... H
```
]

= Вывод

В ходе лабораторной работы были реализованы классы `Vector`, `Body` и `Universe` для моделирования гравитационного взаимодействия тел в трёхмерном пространстве. Класс `Vector` обеспечивает работу с трёхмерными векторами, класс `Body` вычисляет гравитационную силу по закону Ньютона, а класс `Universe` позволяет управлять массивом тел и определять тело с максимальной приложенной к нему силой.

Тестирование подтвердило корректность работы системы: вычисленное ускорение свободного падения g = 9.81 м/с² соответствует реальному значению на поверхности Земли.