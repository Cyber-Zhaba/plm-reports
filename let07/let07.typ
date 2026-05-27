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
  lab_number: "7",
  course: "Языки и методы программирования",
  theme: "Функциональный подход. Roots<T>. GUI-построение траектории",
  year: "2026"
)

#outline()

= Цель работы

Изучить функциональный подход в Java с использованием интерфейсов Function и Consumer. Реализовать универсальный класс Roots<T> для нахождения корней уравнений. Создать GUI-приложение для визуализации траектории брошенного камня.

*Задачи:*
- Изучить функциональные интерфейсы Java.
- Реализовать класс Roots<T> с методами map() и forEach().
- Найти корни квадратного уравнения для траектории камня.
- Создать GUI для построения траектории.


= Теоретические сведения

== Функциональные интерфейсы

Java предоставляет встроенные функциональные интерфейсы в пакете java.util.function:
- `Function<T, R>` — преобразование объекта T в объект R
- `Consumer<T>` — обработка объекта без возврата значения
- `Supplier<T>` — создание объекта
- `Predicate<T>` — проверка условия

== Метод map()

Метод map() применяет функцию к каждому элементу коллекции, возвращая новую коллекцию с преобразованными элементами.


= Задание 1: Квадратное уравнение

Класс Roots<T> реализует функциональный подход для работы с корнями уравнений.

== Класс Point

#terminal(title: "Point.java")[
```java
public class Point {
  private double x, y;

  public Point(double x, double y) {
    this.x = x;
    this.y = y;
  }

  public double dist() {
    return Math.sqrt(x * x + y * y);
  }

  public String toString() {
    return String.format("(%.2f, %.2f)", x, y);
  }
}
```
]

== Класс Roots

#terminal(title: "Roots.java")[
```java
public class Roots<T> {
  private HashSet<T> container;

  private Roots(HashSet<T> container) {
    this.container = container;
  }

  public static Roots<Double> of(double a, double b, double c, double eps) {
    HashSet<Double> roots = new HashSet<>();
    if (a == 0.0) {
      if (b != 0.0) {
        roots.add(-c / b);
      }
    } else {
      double d = b * b - 4 * a * c;
      if (d >= 0.0) {
        if (d < eps)
          d = 0.0;
        roots.add((-b + Math.sqrt(d)) / (2 * a));
        roots.add((-b - Math.sqrt(d)) / (2 * a));
      }
    }
    return new Roots<>(roots);
  }

  public <R> Roots<R> map(Function<T, R> f) {
    HashSet<R> c = new HashSet<>();
    for (T t : container) {
      c.add(f.apply(t));
    }
    return new Roots<>(c);
  }

  public void forEach(Consumer<T> f) {
    for (T t : container) {
      f.accept(t);
    }
  }
}
```
]

== Главный класс Stone

#terminal(title: "Stone.java")[
```java
public class Stone {
  private static final double G = 9.81;

  public static void main(String[] args) {
    Scanner sc = new Scanner(System.in);
    double v = sc.nextDouble();
    double fi = sc.nextDouble() * Math.PI / 180;
    double h = sc.nextDouble();

    Roots.of(-G / 2, v * Math.sin(fi), -h, 1e-10)
        .map(t -> new Point(t * v * Math.cos(fi), h))
        .map(pt -> pt.dist())
        .forEach(x -> System.out.println(x));
  }
}
```
]

Вычисление траектории камня:
Вычисление траектории камня:
- Уравнение: h plus v sin(phi) t минус g делить на 2 t в квадрате = 0
- Решения — моменты времени, когда камень на высоте h = 0 (начало и конец полета)
- После нахождения t: координаты x = v cos(phi) t, y = h

= Задание 2: Полиномы

Расширенный класс Roots для нахождения корней полиномов.

== Метод eval()

Вычисление значения полинома $A_0 x^n + A_1 x^{n-1} + ... + A_n$:

#terminal(title: "Roots.java")[
```java
private static double eval(double[] A, double x) {
  double result = 0.0;
  for (double a : A) {
    result = result * x + a;
  }
  return result;
}
```
]

Это схема Горнера.

== Метод of() для полиномов

#terminal(title: "Roots.java")[
```java
public static Roots<Double> of(double[] A, double step, double eps) {
  HashSet<Double> roots = new HashSet<>();
  // поиск корней на интервале
  double maxCoef = Math.abs(A[0]);
  for (double c : A) {
    if (maxCoef < Math.abs(c)) {
      maxCoef = Math.abs(c);
    }
  }

  double leftBound = -maxCoef - 1;
  double rightBound = -leftBound;
  double previous = eval(A, leftBound);

  for (double t = leftBound; t <= rightBound; t += step) {
    double current = eval(A, t);
    // проверка смены знака
    if (sign(previous) != sign(current)) {
      // метод половинного деления
      double l = t - step;
      double r = t;
      while (r - l > eps) {
        double m = l + (r - l) / 2;
        if (sign(eval(A, m)) != sign(eval(A, l))) {
          r = m;
        } else {
          l = m;
        }
      }
      roots.add((l + r) / 2);
    }
    previous = current;
  }
  return new Roots<>(roots, A);
}
```
]

== Метод toPoints()

#terminal(title: "Roots.java")[
```java
public Roots<Point> toPoints() {
  HashSet<Point> c = new HashSet<>();
  for (T t : container) {
    c.add(new Point((Double) t, eval(A, (Double) t)));
  }
  return new Roots<>(c, A);
}
```
]

== Тестирование

#terminal(title: "Test.java")[
```java
public class Test {
  public static void main(String[] args) {
    // 5x⁴ - 2x² + 3x - 9 = 0
    Roots.of(new double[] { 5, 0, -2, 3, -9 }, 1e-2, 1e-2)
        .toPoints()
        .forEach(x -> System.out.println(x));

    // x⁶ - 64 = 0
    Roots.of(new double[] { 1, 0, 0, 0, 0, 0, -64 }, 1e-5, 1e-9)
        .forEach(x -> System.out.println(x));
  }
}
```
]


= Задание 3: GUI Построение траектории

GUI-приложение для визуализации траектории брошенного камня.

== Класс Plot

#terminal(title: "Plot.java")[
```java
public class Plot extends JFrame {
  private JSpinner gSpinner;
  private JSpinner angleSpinner;
  private JSpinner velocitySpinner;
  private JSpinner heightSpinner;
  private TrajectoryPanel trajectoryPanel;

  public Plot() {
    setTitle("Stone Trajectory");
    setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    setLayout(new BorderLayout(10, 10));

    JPanel controls = new JPanel(new GridLayout(2, 4, 10, 5));
    // элементы управления
    gSpinner = createSpinner(9.81, 0.1, 50.0, 0.1);
    angleSpinner = createSpinner(45.0, 0.0, 90.0, 1.0);
    velocitySpinner = createSpinner(10.0, 0.1, 100.0, 0.5);
    heightSpinner = createSpinner(0.0, 0.0, 100.0, 1.0);

    add(controls, BorderLayout.NORTH);
    trajectoryPanel = new TrajectoryPanel();
    add(trajectoryPanel, BorderLayout.CENTER);
  }
}
```
]

== Панель рисования TrajectoryPanel

#terminal(title: "Plot.java")[
```java
private class TrajectoryPanel extends JPanel {
  @Override
  protected void paintComponent(Graphics g) {
    super.paintComponent(g);
    Graphics2D g2 = (Graphics2D) g;

    double G = ((Number) gSpinner.getValue()).doubleValue();
    double angleDeg = ((Number) angleSpinner.getValue()).doubleValue();
    double v = ((Number) velocitySpinner.getValue()).doubleValue();
    double h = ((Number) heightSpinner.getValue()).doubleValue();

    double fi = angleDeg * Math.PI / 180;
    double a = -G / 2;
    double b = v * Math.sin(fi);
    double c = -h;

    double d = b * b - 4 * a * c;
    double flightTime = 0;
    if (d >= 0) {
      double t1 = (-b + Math.sqrt(d)) / (2 * a);
      double t2 = (-b - Math.sqrt(d)) / (2 * a);
      flightTime = Math.max(Math.max(t1, t2), 0);
    }

    // рисование траектории
    Path2D path = new Path2D.Double();
    for (double t = 0; t <= flightTime; t += flightTime / 200) {
      double x = v * Math.cos(fi) * t;
      double y = h + v * Math.sin(fi) * t - G / 2 * t * t;
      // добавление точек
    }
    g2.draw(path);
  }
}
```
]

== Makefile

#terminal(title: "Makefile")[
```makefile
.PHONY: all clean run

all:
	javac -cp lib/flatlaf-3.7.jar -d out src/*.java

run:
	java -cp out:lib/flatlaf-3.7.jar Plot

clean:
	rm -f out/*.class
```
]

== Запуск

#terminal(title: "terminal")[
```bash
$ make
$ make run
```
]
- G (m/s²) — ускорение свободного падения
- Angle (°) — угол запуска
- Velocity (m/s) — начальная скорость
- Height (m) — начальная высота

И траектория камня отображается на холсте.


= Вывод

В ходе лабораторной работы были реализованы:

1. **Функциональный класс Roots<T>** — универсальный контейнер для корней уравнений с методами map() и forEach()

2. **Решение квадратного уравнения** — нахождение корней для вычисления траектории камня

3. **Решение полиномов** — численный метод для нахождения корней произвольного полинома

4. **GUI-приложение Plot** — визуализация траектории брошенного камня с использованием FlatLaF и Swing

Функциональный подход в Java позволяет писать лаконичный код с использованием лямбда-выражений и цепочек методов.