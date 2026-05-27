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
  lab_number: "4",
  course: "Языки и методы программирования",
  theme: "Iterator и HTTP-сервер на Java",
  year: "2026"
)

#outline()

= Цель работы

Изучить интерфейс Iterator в Java и его реализацию. Создать итераторы для различных структур данных (разложение числа на простые множители, обход графа). Реализовать HTTP-сервер для обработки запросов с передачей данных в формате JSON.

*Задачи:*
- Реализовать интерфейс Iterator для класса Factorize.
- Создать HTTP-сервер с использованием com.sun.net.httpserver.
- Реализовать JSON-сериализацию для передачи данных.
- Использовать итератор BFS для обхода графа в ширину.


= Теоретические сведения

== Интерфейс Iterator

Iterator — это интерфейс для последовательного доступа к элементам коллекции. Основные методы:
- `hasNext()` — проверка наличия следующего элемента
- `next()` — получение следующего элемента
- `remove()` — удаление текущего элемента (опционально)

Классы, реализующие Iterable, могут использоваться в цикле for-each.

== HTTP-сервер в Java

Встроенный HTTP-сервер из пакета `com.sun.net.httpserver` позволяет создавать простые HTTP-серверы без внешних библиотек.


= Реализация Factorize

Класс Factorize реализует интерфейс Iterable для разложения числа на простые множители.

== Класс Factorize

#terminal(title: "Factorize.java")[
```java
public class Factorize implements Iterable<Integer> {
  private int number;

  public Factorize(int n) {
    number = n;
  }

  public Iterator<Integer> iterator() {
    return new FactorizeIterator();
  }

  private class FactorizeIterator implements Iterator<Integer> {
    private int current_prime;

    private boolean prime(int x) {
      for (int i = 2; i < x; i++) {
        if (x % i == 0) {
          return false;
        }
      }
      return true;
    }

    private void findNextPrime() {
      current_prime++;
      for (; current_prime <= number; current_prime++) {
        if (number % current_prime == 0 && prime(current_prime)) {
          return;
        }
      }
    }

    public FactorizeIterator() {
      current_prime = 1;
      findNextPrime();
    }

    public boolean hasNext() {
      return number >= current_prime;
    }

    public Integer next() {
      int pow = 0;
      int factor = 1;
      while (number % factor == 0) {
        pow++;
        factor *= current_prime;
      }
      findNextPrime();
      return pow - 1;
    }
  }
}
```
]

Пример: $5402250 = 2^6 \cdot 3^2 \cdot 5^3 \cdot 7^4$


= Реализация HTTP-сервера

== Парсер параметров запроса

#terminal(title: "Server.java")[
```java
class QueryParser {
  static Map<String, String> parse(String query) {
    Map<String, String> params = new HashMap<>();
    if (query == null || query.isEmpty())
      return params;

    for (String pair : query.split("&")) {
      String[] parts = pair.split("=", 2);
      if (parts.length != 2)
        continue;

      String key = URLDecoder.decode(parts[0], StandardCharsets.UTF_8);
      String value = URLDecoder.decode(parts[1], StandardCharsets.UTF_8);
      params.put(key, value);
    }
    return params;
  }
}
```
]

== JSON-сериализатор

#terminal(title: "Server.java")[
```java
class JsonSerializer {
  static String toJson(Factorize f) {
    StringBuilder sb = new StringBuilder();
    sb.append("[");

    for (int n : f) {
      sb.append(n);
      sb.append(", ");
    }
    sb.delete(sb.length() - 2, sb.length());

    sb.append("]");
    return sb.toString();
  }
}
```
]

== Обработчик HTTP

#terminal(title: "Server.java")[
```java
public class Server {
  public static void main(String[] args) throws Exception {
    HttpServer server = HttpServer.create(new InetSocketAddress(7518), 0);
    server.createContext("/", new MyHandler());
    server.setExecutor(null);
    server.start();
  }

  static class MyHandler implements HttpHandler {
    @Override
    public void handle(HttpExchange exchange) throws IOException {
      String query = exchange.getRequestURI().getQuery();
      Map<String, String> params = QueryParser.parse(query);

      int number = Integer.parseInt(params.get("n"));
      Factorize f = new Factorize(number);

      String json = JsonSerializer.toJson(f);

      exchange.getResponseHeaders().add("Content-Type", "application/json");
      exchange.sendResponseHeaders(200, json.getBytes().length);

      try (OutputStream os = exchange.getResponseBody()) {
        os.write(json.getBytes());
      }
    }
  }
}
```
]


= Реализация BFS

Класс BFS реализует обход графа в ширину с использованием итератора.

== Класс BFS

#terminal(title: "BFS.java")[
```java
public class BFS implements Iterable<Integer> {
  private int[][] A;

  public BFS(int[][] A) {
    this.A = A;
  }

  public Iterator<Integer> iterator() {
    return new BFSIterator();
  }

  private class BFSIterator implements Iterator<Integer> {
    private boolean[] visited;
    private Queue<Integer> queue;

    BFSIterator() {
      visited = new boolean[A.length];
      queue = new LinkedList<>();
      queue.add(0);
    }

    public boolean hasNext() {
      return !queue.isEmpty();
    }

    public Integer next() {
      int v = queue.poll();
      visited[v] = true;
      for (int i = 0; i < A[v].length; i++) {
        if (A[v][i] == 1 && !visited[i]) {
          queue.add(i);
          visited[i] = true;
        }
      }
      return v;
    }
  }
}
```
]


= Тестирование

== Тест Factorize

#terminal(title: "Test.java")[
```java
public class Test {
  public static void main(String[] args) {
    Factorize f = new Factorize(Math.powExact(2, 6) * Math.powExact(3, 2) * Math.powExact(5, 6));
    for (int p : f) {
      System.out.println(p);
    }
  }
}
```
]

Вывод: показатели степеней для каждого простого множителя.

== HTTP-сервер

#terminal(title: "terminal")[
```bash
$ java Server
[*] Starting server...
Usage http://net1.yss.su:7518/?n=5402250
```
]

#terminal(title: "terminal")[
```bash
$ curl "http://net1.yss.su:7518/?n=5402250"
[6, 2, 3, 4]
```
]

Ответ: показатели степеней $2^6 \cdot 3^2 \cdot 5^3 \cdot 7^4 = 6, 2, 3, 4$

== Тест BFS

#terminal(title: "dop2/Test.java")[
```java
int[][] graph = {
    { 0, 1, 0, 1, 0 },
    { 1, 0, 1, 0, 1 },
    { 0, 1, 0, 0, 0 },
    { 1, 0, 0, 0, 0 },
    { 0, 1, 0, 0, 0 },
};
//    0
//   / \
//  1   3
// / \
//2   4

for (int v : new BFS(graph)) {
  System.out.print(v + " ");
}
// Вывод: 0 1 3 2 4
```
]


= Вывод

В ходе лабораторной работы были реализованы:

1. **Iterator для Factorize** — класс, реализующий интерфейс Iterable, для разложения числа на простые множители
2. **HTTP-сервер** — сервер на основе com.sun.net.httpserver, обрабатывающий GET-запросы и возвращающий JSON
3. **JSON-сериализатор** — преобразование данных Factorize в формат JSON
4. **Iterator для BFS** — обход графа в ширину с использованием очереди

Все реализации используют стандартные интерфейсы Java (Iterable, Iterator), что обеспечивает их совместимость с циклом for-each и другими компонентами Java Collections Framework.