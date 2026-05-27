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
  lab_number: "8",
  course: "Языки и методы программирования",
  theme: "C++. Статические поля. new и delete",
  year: "2026",
)

#outline()

= Цель работы

Изучить основы объектно-ориентированного программирования на C++. Реализовать классы Point и Universe с использованием статических полей, конструкторов, деструкторов и динамического выделения памяти.

*Задачи:*
- Реализовать класс Point со статическим счетчиком.
- Использовать список инициализации конструктора.
- Реализовать виртуальный деструктор.
- Управлять динамической памятью с new и delete.


= Класс Point

Класс Point представляет точку на плоскости с координатами x и y.

== Реализация класса

#terminal(title: "main.cpp")[
  ```cpp
  class Point {
     private:
      static int counter;

     public:
      int id;
      double x, y;

      Point();
      virtual ~Point();

      void print();
  };

  int Point::counter = 0;
  ```
]

Статическое поле counter хранит количество созданных объектов Point и увеличивается при каждом создании.

== Конструктор

#terminal(title: "main.cpp")[
  ```cpp
  int myrand() { return rand() % 20; }

  Point::Point() : id(counter++), x(myrand()), y(myrand()) {
      std::cout << "Created new Point(" << x << ' ' << y << ") id = " << id << "\n";
  }
  ```
]

Список инициализации: id(counter++) инициализирует id значением counter и затем увеличивает counter.

== Деструктор

#terminal(title: "main.cpp")[
  ```cpp
  Point::~Point() { cout << "Point " << id << " selfdestructed!!!!\n"; }
  ```
]

Виртуальный деструктор гарантирует правильное освобождение памяти при удалении через указатель на базовый класс.

== Метод print()

#terminal(title: "main.cpp")[
  ```cpp
  void Point::print() { std::cout << "Point (" << x << ' ' << y << ") id = " << id << "\n"; }
  ```
]


= Класс Universe

Класс Universe представляет набор точек.

== Реализация

#terminal(title: "main.cpp")[
  ```cpp
  class Universe {
     public:
      int size;
      Point* points;

      Universe();
      virtual ~Universe();
  };
  ```
]

Поле points является указателем на массив объектов Point.

== Конструктор

#terminal(title: "main.cpp")[
  ```cpp
  Universe::Universe() : size(myrand()), points(new Point[size]) {
      std::cout << "Universe created!\n";
  }
  ```
]

Динамическое выделение памяти: new Point[size] создает массив из size объектов Point.

== Деструктор

#terminal(title: "main.cpp")[
  ```cpp
  Universe::~Universe() {
      for (int i = 0; i < size; i++) {
          points[i].~Point();
      }
      delete[] points;
  }
  ```
]

Явный вызов деструктора для каждого объекта и освобождение памяти с delete[].


= main()

#terminal(title: "main.cpp")[
  ```cpp
  int main() {
      Universe Andrey_Kabanov;

      std::cout << "\n";
      for (int i = 0; i < Andrey_Kabanov.size; i++) {
          Andrey_Kabanov.points[i].print();
      }
      std::cout << "\n";
  }
  ```
]


= Компиляция и запуск

== Makefile

#terminal(title: "Makefile")[
  ```makefile
  .PHONY: all run clean

  all:
  	g++ -o a.out main.cpp -std=c++17

  run: all
  	./a.out

  clean:
  	rm -f a.out
  ```
]

== Компиляция и запуск

#terminal(title: "terminal")[
  ```bash
  $ make
  $ make run
  Created new Point(...id = 0)
  Created new Point(...id = 1)
  ...
  Universe created!

  Point (...id = 0)
  Point (...id = 1)
  ...
  Point 0 selfdestructed!!!!
  Point 1 selfdestructed!!!!
  ...
  ```
]


= Ключевые понятия C++

1. **Статическое поле** — поле, общее для всех объектов класса
2. **Список инициализации** — инициализация полей в конструкторе до выполнения тела
3. **Виртуальный деструктор** — обеспечивает правильное удаление производных классов
4. **new и delete** — выделение и освобождение динамической памяти
5. **new[] и delete[]** — работа с массивами


= Вывод

В ходе лабораторной работы были изучены основы C++:

1. Статический счетчик counter для учета созданных объектов
2. Список инициализации конструктора для эффективной инициализации полей
3. Виртуальный деструктор для правильного управления памятью
4. Динамическое выделение памяти с new и освобождение с delete

Эти концепции являются фундаментом объектно-ориентированного программирования на C++.

