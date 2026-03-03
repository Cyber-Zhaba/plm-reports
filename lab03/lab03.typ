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
  lab_number: "3",
  course: "Языки и методы программирования",
  theme: "Класс булевских матриц с порядком на основе подсчёта равных строк и столбцов",
  year: "2026",
)

#outline()

= Цель работы

Целью данной работы является изучение интерфейсов и классов коллекций в языке Java, реализация интерфейса `Comparable` для создания упорядочиваемых типов данных.

= Индивидуальный вариант

Класс булевских матриц размера $m times n$ с порядком на основе суммарного количества строк и столбцов, все элементы которых равны между собой.

Дополнительно выполнено:
- Добавление лабораторной работы в веб-сервер (+1 балл);
- Запуск на VDS (+1 балл).

= Реализация

Создан класс `BoolMatrix`, реализующий интерфейс `Comparable<BoolMatrix>`.

== Класс BoolMatrix

Класс `BoolMatrix` представляет булевскую матрицу размера $m times n$ и содержит:
- Конструктор из `int[][]`;
- Конструктор из строки и размеров;
- Метод `getOrd()` для вычисления порядка (количество строк и столбцов, где все элементы равны между собой);
- Метод `compareTo()` для сравнения матриц по порядку;
- Метод `toString()` для строкового представления.

#terminal(title: "BoolMatrix.java (конструкторы)")[
  ```java
  public class BoolMatrix implements Comparable<BoolMatrix> {
    private boolean[][] matrix;
    private int m, n;

    public BoolMatrix(int[][] matrix) {
      m = matrix.length;
      if (m > 0) {
        n = matrix[0].length;
      } else {
        n = 0;
      }

      this.matrix = new boolean[m][n];

      for (int i = 0; i < m; i++) {
        for (int j = 0; j < n; j++) {
          this.matrix[i][j] = matrix[i][j] == 1;
        }
      }
    }

    public BoolMatrix(String data, int rows, int cols) {
      this.m = rows;
      this.n = cols;
      this.matrix = new boolean[m][n];
      for (int i = 0; i < m; i++) {
        for (int j = 0; j < n; j++) {
          int idx = i * n + j;
          this.matrix[i][j] = data.charAt(idx) == '1';
        }
      }
    }
  ```
]

#terminal(title: "BoolMatrix.java (метод getOrd)")[
  ```java
    public int getOrd() {
      int total_good_rows_and_cols = 0;

      for (int i = 0; i < m; i++) {
        boolean is_good = true;
        for (int j = 1; j < n; j++) {
          if (matrix[i][j] != matrix[i][0]) {
            is_good = false;
            break;
          }
        }

        if (is_good) {
          total_good_rows_and_cols++;
        }
      }

      for (int j = 0; j < n; j++) {
        boolean is_good = true;
        for (int i = 1; i < m; i++) {
          if (matrix[i][j] != matrix[0][j]) {
            is_good = false;
            break;
          }
        }

        if (is_good) {
          total_good_rows_and_cols++;
        }
      }

      return total_good_rows_and_cols;
    }
  ```
]

#terminal(title: "BoolMatrix.java (методы compareTo и toString)")[
  ```java
    public int compareTo(BoolMatrix other) {
      int ord = getOrd();
      int other_ord = other.getOrd();

      if (ord > other_ord) {
        return 1;
      } else if (ord < other_ord) {
        return -1;
      }
      return 0;
    }

    public String toString() {
      String result = "";

      for (int i = 0; i < m; i++) {
        for (int j = 0; j < n; j++) {
          if (matrix[i][j]) {
            result += "1";
          } else {
            result += "0";
          }
          if (j != n - 1) {
            result += " ";
          }
        }
        if (i != m - 1) {
          result += "\n";
        }
      }
      return result;
    }
  }
  ```
]

== HTTP-сервер

Сервер реализован в файле `Server.java` с использованием встроенного класса `com.sun.net.httpserver.HttpServer`. Сервер:
- Слушает порт 7513;
- Обрабатывает GET-запросы;
- Принимает параметры двух матриц (`mat1`, `mat2`) с их размерами;
- Возвращает JSON-ответ с представлением матриц и их порядком.


= Протокол тестирования

Запуск сервера производится командой:

#terminal(title: "server@net1.yss.su")[
  ```bash
  java Server.java
  ```
]

Тестирование выполняется с помощью утилиты `curl`.

== Тест 1: Матрица без равных строк и столбцов

#terminal(title: "arseny@local-pc")[
  ```bash
    $ java Test.java
  1 0 0 1
  0 1 1 0
  1 1 0 0
  This matrix has 0 equal rows & cols

  1 0 0 1
  1 1 1 1
  1 1 0 1
  1 1 0 1
  This matrix has 3 equal rows & cols

  1 1
  1 1
  This matrix has 4 equal rows & cols
  ```
]

== Тест через веб-сервер

#terminal(title: "arseny@local-pc")[
  ```bash
  $ curl "http://net1.yss.su:7513/?arr_lenght=2&mat1_n=2&mat1_m=2&mat1=0101&mat2_n=2&mat2_m=2&mat2=1111"
  [
  {"matrix": "0 1\n0 1", "metadata": "This matrix has 2 equal rows & cols"},
  {"matrix": "1 1\n1 1", "metadata": "This matrix has 4 equal rows & cols"}
  ]
  ```
]

= Вывод

В ходе лабораторной работы был реализован класс `BoolMatrix`, представляющий булевские матрицы размера $m times n$. Класс реализует интерфейс `Comparable<BoolMatrix>`, позволяющий сравнивать матрицы по порядку — суммарному количеству строк и столбцов, все элементы которых равны между собой.

Созданный HTTP-сервер успешно обрабатывает GET-запросы, парсит параметры матриц и возвращает результаты в формате JSON. Тестирование подтвердило корректность работы алгоритма вычисления порядка для различных матриц.
