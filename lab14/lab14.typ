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
  lab_number: "14",
  course: "Языки и методы программирования",
  theme: "N-body problem. BigInteger. Рациональная арифметика. ncurses",
  year: "2026",
)

#outline()

= Цель работы

Реализовать симуляцию гравитационного взаимодействия N тел с использованием арифметики произвольной точности (BigInteger и Rational). Визуализировать движение тел в консоли с помощью библиотеки ncurses.

= Архитектура проекта

Проект состоит из пяти основных компонентов:

- `BigInteger` / `Rational` — библиотека арифметики произвольной точности;
- `Body` — представление одного небесного тела;
- `Universe` — физический движок (расчёт сил, интеграция уравнений движения);
- `Visualizer` — консольная визуализация через ncurses;
- `test.cpp` — модульные тесты.

Сборка осуществляется через CMake с единственной внешней зависимостью — `ncursesw`.

= BigInteger и Rational

Ядро проекта — реализация целых чисел произвольной точности (`BigInteger`) и рациональных чисел (`Rational`) на их основе.

== BigInteger

`BigInteger` хранит число в системе с основанием 2^32 с помощью `std::vector<unsigned int>`. Поддерживаются:

- сложение, вычитание, умножение, деление, остаток;
- бинарные сдвиги (`<<`, `>>`);
- конвертация в `double` и строку произвольной точности;
- пользовательский литерал `_bi`.

Умножение реализовано бинарным алгоритмом (сдвиг + сложение), деление — побитовым делением в столбик.

#terminal(title: "include/biginteger.h — фрагмент")[
```cpp
class BigInteger {
  std::vector<unsigned int> digits;
  bool isNegative;

public:
  BigInteger() : isNegative(false) { digits.push_back(0); }
  BigInteger(long long num);

  BigInteger operator+(const BigInteger &other) const;
  BigInteger operator-(const BigInteger &other) const;
  BigInteger operator*(const BigInteger &other) const;
  BigInteger operator/(const BigInteger &other) const;

  explicit operator double() const;
  std::string toString() const;

  friend BigInteger operator""_bi(const char *str);
};
```
]

== Rational

`Rational` представляет число в виде числитель / знаменатель (оба — `BigInteger`). После каждой операции выполняется нормализация через GCD. Поддерживаются:

- конструкторы от `int`, `BigInteger`, `double`, `const char*` (включая экспоненциальную запись);
- арифметические операции;
- метод `asDecimal(precision)` для форматированного вывода;
- конвертация в `double`.

#terminal(title: "include/biginteger.h — фрагмент Rational")[
```cpp
class Rational {
  BigInteger num;
  BigInteger den;

  void normalize();

public:
  Rational() : num(0), den(1) {}
  Rational(BigInteger n, BigInteger d);
  Rational(double d);
  Rational(const char *decimalStr);

  Rational operator+(const Rational &other) const;
  Rational operator-(const Rational &other) const;
  Rational operator*(const Rational &other) const;
  Rational operator/(const Rational &other) const;

  std::string asDecimal(int precision) const;
  explicit operator double() const;
};
```
]

= Класс Body

Хранит состояние одного тела: координаты (x, y), скорость (vx, vy) и массу. Все величины имеют тип `Rational`.

#terminal(title: "include/Body.hpp")[
```cpp
class Body {
  Rational m_x, m_y;
  Rational m_vx, m_vy;
  Rational m_mass;

public:
  Body(const Rational &x, const Rational &y,
       const Rational &vx, const Rational &vy,
       const Rational &mass);

  Rational getX() const;
  Rational getY() const;
  Rational getVx() const;
  Rational getVy() const;
  Rational getMass() const;

  void setX(const Rational &x);
  void setY(const Rational &y);
  void setVx(const Rational &vx);
  void setVy(const Rational &vy);
};
```
]

= Класс Universe

Содержит вектор тел и реализует шаг симуляции гибридным методом:

1. **Расчёт ускорений** выполняется в `double` (требуется `std::sqrt`):
   - для каждой пары (i, j) вычисляется расстояние R = sqrt(dx^2 + dy^2);
   - ускорение a_j += G * m_i / R^3 * (r_i - r_j).

2. **Обновление позиций и скоростей** выполняется в `Rational`:
   - x += v \* dt + 0.5 \* a \* dt \* dt (Taylor expansion второго порядка);
   - v += a \* dt.

Сложность алгоритма — O(N^2) (direct summation, без Barnes-Hut). Параллелизация отсутствует.

#terminal(title: "src/Universe.cpp")[
```cpp
void Universe::step(const Rational &dt) {
  size_t n = m_bodies.size();
  std::vector<double> ax(n, 0.0), ay(n, 0.0);
  double G = m_G.toDouble();

  // Вычисление ускорений (двойная точность для sqrt)
  for (size_t j = 0; j < n; ++j) {
    double xj = m_bodies[j].getX().toDouble();
    double yj = m_bodies[j].getY().toDouble();
    for (size_t i = 0; i < n; ++i) {
      if (i == j) continue;
      double xi = m_bodies[i].getX().toDouble();
      double yi = m_bodies[i].getY().toDouble();
      double mi = m_bodies[i].getMass().toDouble();
      double dx = xi - xj;
      double dy = yi - yj;
      double R = std::sqrt(dx * dx + dy * dy);
      double R3 = R * R * R;
      ax[j] += G * mi / R3 * dx;
      ay[j] += G * mi / R3 * dy;
    }
  }

  // Обновление состояния (рациональная арифметика)
  for (size_t i = 0; i < n; ++i) {
    Rational newX = m_bodies[i].getX()
        + m_bodies[i].getVx() * dt
        + Rational(ax[i]) * dt * dt / Rational(2);
    Rational newY = m_bodies[i].getY()
        + m_bodies[i].getVy() * dt
        + Rational(ay[i]) * dt * dt / Rational(2);
    Rational newVx = m_bodies[i].getVx() + Rational(ax[i]) * dt;
    Rational newVy = m_bodies[i].getVy() + Rational(ay[i]) * dt;

    m_bodies[i].setX(newX);
    m_bodies[i].setY(newY);
    m_bodies[i].setVx(newVx);
    m_bodies[i].setVy(newVy);
  }
}
```
]

= Класс Visualizer

Использует библиотеку `ncursesw` для консольной анимации.

== Возможности

- отображение тел символами `'O'` разных цветов (до 7 цветовых пар);
- автоматический расчёт масштаба по начальным координатам;
- HUD: номер шага, dt, количество тел, состояние паузы;
- управление: `q` (выход), `p` (пауза), `+` (ускорить в 1.5 раза), `-` (замедлить в 1.5 раза).

#terminal(title: "include/Visualizer.hpp")[
```cpp
class Visualizer {
  Universe &m_universe;
  Rational m_dt;
  bool m_paused;
  bool m_running;
  double m_viewX, m_viewY, m_scale;

public:
  Visualizer(Universe &u, const Rational &dt);

  void init();
  void run();

  void setDt(const Rational &dt);

private:
  void render();
  void handleInput();
  void shutdown();
};
```
]

= Сценарий threeBody

В `main.cpp` реализован демонстрационный сценарий — задача трёх тел с нормализованными параметрами:

#terminal(title: "src/main.cpp")[
```cpp
int main() {
  Universe universe(Rational("1")); // G = 1

  universe.addBody(Body(-10, 0, 0, -2, 100));
  universe.addBody(Body(10, 0, 0, 2, 100));
  universe.addBody(Body(0, 10, 1.5, 0, 100));

  Rational dt = Rational(2) / Rational(100);
  Visualizer visualizer(universe, dt);
  visualizer.init();
  visualizer.run();

  return 0;
}
```
]

Три тела равной массы (100) расположены в вершинах треугольника и движутся по сложной траектории, демонстрируя хаотическое поведение, характерное для задачи трёх тел.

= Сборка и запуск

#terminal(title: "CMakeLists.txt")[
```cmake
cmake_minimum_required(VERSION 3.16)
project(nbody LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(PkgConfig REQUIRED)
pkg_check_modules(NCURSES REQUIRED ncursesw)

add_executable(nbody
  src/main.cpp src/Body.cpp src/Universe.cpp
  src/Visualizer.cpp src/biginteger.cpp
)
target_include_directories(nbody PRIVATE include ${NCURSES_INCLUDE_DIRS})
target_link_libraries(nbody PRIVATE ${NCURSES_LIBRARIES})
target_compile_options(nbody PRIVATE -Wall -Wextra -Wpedantic)

add_executable(nbody_test
  src/test.cpp src/Body.cpp src/Universe.cpp src/biginteger.cpp
)
target_include_directories(nbody_test PRIVATE include)
target_compile_options(nbody_test PRIVATE -Wall -Wextra -Wpedantic)
```
]

#terminal(title: "Makefile")[
```makefile
build:
	cmake -B build -DCMAKE_BUILD_TYPE=Release
	cmake --build build

run: build
	./build/nbody

test: build
	./build/nbody_test

clean:
	rm -rf build

.PHONY: build run test clean
```
]

Запуск: `make run` (сборка + запуск) или `make test` (модульные тесты).

= Тестирование

Тесты реализованы в `src/test.cpp` с использованием простого макросного фреймворка (`TEST` / `END_TEST`, проверка через `assert`):

- конструкторы `Rational` от строки и `double`;
- арифметические операции с большими числами;
- конвертация `Rational -> double -> Rational` (round-trip);
- тест гравитационной постоянной G;
- конструктор и геттеры/сеттеры `Body`;
- симуляция `Universe::step()` на 100 и 2000 шагов (проверка отсутствия NaN/Inf).

= Вывод

В ходе лабораторной работы реализована симуляция гравитационного взаимодействия N тел с использованием:

- арифметики произвольной точности (BigInteger с основанием 2^32, Rational с GCD-нормализацией);
- прямого O(N^2) алгоритма расчёта сил с гибридной точностью (double для ускорений, Rational для координат);
- консольной визуализации через ncursesw с цветами и управлением в реальном времени.

Код отформатирован по стилю LLVM (`.clang-format`) и проверен статическим анализатором (`.clang-tidy`). Сборка осуществляется через CMake с единственной зависимостью `ncursesw`.
