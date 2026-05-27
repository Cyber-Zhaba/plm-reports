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
  lab_number: "9",
  course: "Языки и методы программирования",
  theme: "DSU (Disjoint Set Union) в C++",
  year: "2026"
)

#outline()

= Цель работы

Реализовать структуру данных DSU (Disjoint Set Union, система непересекающихся множеств) на C++. DSU используется для эффективного объединения множеств и проверки принадлежности одному множеству.

*Задачи:*
- Изучить структуру данных DSU.
- Реализовать класс Element с find и union.
- Использовать перегрузку операторов.
- Применить path compression и union by rank.


= Теоретические сведения

DSU (Disjoint Set Union) — структура данных для работы с непересекающимися множествами. Основные операции:
- make_set(x) — создание нового множества
- find(x) — поиск представителя множества
- union(x, y) — объединение множеств

Оптимизации:
- Path compression — сжатие пути при find
- Union by rank — объединение по рангу


= Класс Element

Шаблонный класс Element представляет элемент множества.

== dsu.hpp

#terminal(title: "dsu.hpp")[
```cpp
template <typename T> class Element {
private:
  T value;
  Element<T> *parent;
  int rank;

public:
  Element(T val) : value(val), parent(this), rank(0) {}

  T &operator*() { return value; }

  Element<T> *operator!() { ... }

  Element<T> *find() { ... }

  Element<T> *find() const { ... }

  bool operator==(const Element<T> &other) const { ... }

  bool operator!=(const Element<T> &other) const { ... }

  void operator<<(Element<T> &other) { ... }
};
```
]

- value — хранимое значение
- parent — указатель на родителя (в дереве)
- rank — ранг для оптимизации union


= Операторы

== Operator dereference

#terminal(title: "dsu.hpp")[
```cpp
T &operator*() { return value; }
```
]

Возвращает ссылку на хранимое значение.

== Оператор find !

#terminal(title: "dsu.hpp")[
```cpp
Element<T> *operator!() {
  if (parent == this) {
    return this;
  }
  return parent = !(*parent);
}
```
]

Перегрузка оператора ! для find с path compression. При вызове возвращает корень множества и сжимает путь.

== Метод find()

#terminal(title: "dsu.hpp")[
```cpp
Element<T> *find() {
  if (parent == this) {
    return this;
  }
  return parent = parent->find();
}

Element<T> *find() const {
  if (parent == this) {
    return const_cast<Element<T> *>(this);
  }
  return parent->find();
}
```
]

Два варианта: изменяемый и константный. Рекурсивный поиск корня с path compression.

== Оператор сравнения ==

#terminal(title: "dsu.hpp")[
```cpp
bool operator==(const Element<T> &other) const {
  return find() == const_cast<Element<T> &>(other).find();
}

bool operator!=(const Element<T> &other) const {
  return !(*this == other);
}
```
]

Проверка принадлежности одному множеству через сравнение корней.


= Объединение множеств

== Оператор <<

#terminal(title: "dsu.hpp")[
```cpp
void operator<<(Element<T> &other) {
  Element<T> *root1 = find();
  Element<T> *root2 = other.find();

  if (root1 != root2) {
    if (root1->rank < root2->rank) {
      root1->parent = root2;
    } else if (root1->rank > root2->rank) {
      root2->parent = root1;
    } else {
      root2->parent = root1;
      root1->rank++;
    }
  }
}
```
]

Перегрузка оператора << для объединения множеств (аналог union).

Алгоритм union by rank:
- Если rankroot1 < rankroot2 — root1 становится child root2
- Если rankroot1 > rankroot2 — root2 становится child root1
- Если равны — выбираем любой, увеличиваем его rank


= main()

#terminal(title: "main.cpp")[
```cpp
int main() {
  Element<int> a(1);
  Element<int> b(2);
  Element<int> c(3);
  Element<int> d(4);

  auto print = [&]() {
    std::cout << "  a = " << *a << ", root: " << **!a << std::endl;
    std::cout << "  b = " << *b << ", root: " << **!b << std::endl;
    std::cout << "  c = " << *c << ", root: " << **!c << std::endl;
    std::cout << "  d = " << *d << ", root: " << **!d << std::endl;
    std::cout << "---\n";
  };

  print();
  a << b;
  std::cout << "a << b\n";
  print();
  c << d;
  std::cout << "c << d\n";
  print();
  a << c;
  std::cout << "a << c\n";
  print();
}
```
]

Вывод:
```
  a = 1, root: 1
  b = 2, root: 2
  c = 3, root: 3
  d = 4, root: 4
---
a << b
  a = 1, root: 1
  b = 2, root: 1
  c = 3, root: 3
  d = 4, root: 4
---
c << d
  a = 1, root: 1
  b = 2, root: 1
  c = 3, root: 3
  d = 4, root: 3
---
a << c
  a = 1, root: 1
  b = 2, root: 1
  c = 3, root: 1
  d = 4, root: 1
---
```


= Вывод

В ходе лабораторной работы была реализована структура данных DSU:

1. **Класс Element** — шаблонный класс для элементов множества
2. **Path compression** — оптимизация поиска корня
3. **Union by rank** — оптимизация объединения
4. Operator overloading - use operator names instead

DSU применяется в алгоритмах Крускала,connected components, и других задачах с объединением множеств.