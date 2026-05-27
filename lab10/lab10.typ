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
  lab_number: "10",
  course: "Языки и методы программирования",
  theme: "Iterator. Бинарное отношение в C++",
  year: "2026"
)

#outline()

= Цель работы

Реализовать шаблонный класс BinaryRelation с пользовательским итератором для обхода бинарного отношения. Использовать стандартные методы STL для итераторов.

*Задачи:*
- Реализовать шаблонный класс BinaryRelation.
- Создать пользовательский итератор.
- Реализовать begin() и end() для for-each.
- Проверить работу с бинарным отношением.


= Теоретические сведения

Бинарное отношение — это подмножество декартова произведения A x B. В данном случае отношение на множестве 0...N-1, представленное булевой матрицей смежности.

Итератор — это объект, который позволяет перебирать элементы коллекции. Для использования в for-each нужно реализовать:
- begin() — возвращает итератор на первый элемент
- end() — возвращает итератор на элемент после последнего
- Операторы сравнения == и !=
- Оператор инкремента ++


= Класс BinaryRelation

Шаблонный класс BinaryRelation с размером N.

== relation.hpp

#terminal(title: "relation.hpp")[
```cpp
template <unsigned int N> class BinaryRelation {
  bool matrix[N][N];

public:
  BinaryRelation(const bool input[N][N]) {
    for (unsigned int i = 0; i < N; ++i)
      for (unsigned int j = 0; j < N; ++j)
        matrix[i][j] = input[i][j];
  }

  class iterator {
  private:
    const BinaryRelation *parent;
    std::pair<unsigned int, unsigned int> coords;
    unsigned int x, y;

    void advance_to_next() {
      while (x < N) {
        while (y < N) {
          if (parent->matrix[x][y]) {
            coords = {x, y};
            return;
          }
          ++y;
        }
        y = 0;
        ++x;
      }
      x = N;
      y = 0;
    }

  public:
    iterator(const BinaryRelation<N> *parent, unsigned int x, unsigned int y)
        : parent(parent), x(x), y(y), coords({x, y}) {
      advance_to_next();
    }

    std::pair<unsigned int, unsigned int> &operator deref() { return coords; }
    std::pair<unsigned int, unsigned int> *operator arrow() { return &coords; }

    bool operator eq(const iterator &other) const {
      return parent == other.parent && x == other.x && y == other.y;
    }
    bool operator ne(const iterator &other) const { return !(*this == other); }

    iterator &operator inc() {
      ++y;
      if (y == N) {
        y = 0;
        ++x;
      }
      advance_to_next();
      return *this;
    }

    iterator operator inc(int) {
      iterator old = *this;
      ++(*this);
      return old;
    }
  };

  iterator begin() const { return iterator(this, 0, 0); }
  iterator end() const { return iterator(this, N, 0); }
};
```
]

- matrix — булева матрица N x N
- iterator — вложенный класс итератора


= Итератор

Внутренний класс iterator обеспечивает обход бинарного отношения (где matrix[x][y] == true).

== Конструктор

#terminal(title: "relation.hpp")[
```cpp
iterator(const BinaryRelation<N> *parent, unsigned int x, unsigned int y)
    : parent(parent), x(x), y(y), coords({x, y}) {
  advance_to_next();
}
```
]

Конструктор принимает начальные координаты и сразу переходит к первому элементу.

== advance_to_next()

#terminal(title: "relation.hpp")[
```cpp
void advance_to_next() {
  while (x < N) {
    while (y < N) {
      if (parent->matrix[x][y]) {
        coords = {x, y};
        return;
      }
      ++y;
    }
    y = 0;
    ++x;
  }
  x = N;
  y = 0;
}
```
]

Переходит к следующей паре, где matrix[x][y] == true.

== Операторы

#terminal(title: "relation.hpp")[
```cpp
std::pair<unsigned int, unsigned int> &operator deref() { return coords; }
std::pair<unsigned int, unsigned int> *operator arrow() { return &coords; }

bool operator eq(const iterator &other) const {
  return parent == other.parent && x == other.x && y == other.y;
}
bool operator ne(const iterator &other) const { return !(*this == other); }

iterator &operator inc() {
  ++y;
  if (y == N) {
    y = 0;
    ++x;
  }
  advance_to_next();
  return *this;
}
```
]

- operator deref — разыменование
- operator arrow — доступ через указатель
- operator eq и operator ne — сравнение
- operator inc — инкремент (префиксный)


= main()

#terminal(title: "main.cpp")[
```cpp
int main() {
  bool data[4][4] = {
      {0, 1, 0, 0},
      {0, 0, 0, 1},
      {0, 0, 0, 0},
      {0, 0, 0, 1},
  };

  BinaryRelation<4> relation(data);

  std::cout << "Pairs in relation:\n";

  for (const auto &pair : relation) {
    std::cout << "(" << pair.first << ", " << pair.second << ")\n";
  }
}
```
]

Матрица смежности:
- (0,1) — связь 0 -> 1
- (1,3) — связь 1 -> 3
- (3,3) — связь 3 -> 3 (петля)

Вывод:
```
Pairs in relation:
(0, 1)
(1, 3)
(3, 3)
```
]


= Вывод

В ходе лабораторной работы были изучены:

1. **Шаблонный класс BinaryRelation** — представление бинарного отношения
2. **Пользовательский иiterator** — вложенный класс для обхода
3. **Стандартные методы итераторов** — begin, end, ++, ==, !=
4. **For-each** — использование в цикле for (const auto &pair : relation)

Итератор позволяет использовать объект в стиле STL и применять стандартные алгоритмы.
