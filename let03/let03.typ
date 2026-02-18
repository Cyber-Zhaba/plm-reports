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

// --- СТРОГИЙ СТИЛЬ БЛОКА КОДА ---
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
  lab_number: "3",
  course: "Языки и методы программирования",
  theme: "Классы Point и Lineika. HTTP-сервер",
  year: "2026"
)

#outline()

= Цель работы

Реализовать класс `Point` и класс `Lineika`, каждый из которых имеет метод `dist()` для вычисления расстояния между двумя точками. Обернуть классы в веб-сервер и запустить его в фоновом режиме с использованием утилиты `screen`.

*Задачи:*
- Реализовать класс `Point` с методом вычисления расстояния.
- Реализовать класс `Lineika`, использующий метод `dist()` класса `Point`.
- Создать HTTP-сервер, обрабатывающий GET-запросы с параметрами координат.
- Запустить сервер на удалённом сервере и протестировать его работу.


(дополнение)

Измерить скорость загрузки класса Point и Lineika на основе лекции по static-блокам (https://dzen.ru/video/watch/699427bf517c8272770d72c9)

= Реализация классов

Созданы три файла: `Point.java`, `Lineika.java` и `Test.java` (веб-сервер).

== Класс Point

Класс `Point` представляет точку на плоскости с координатами `x` и `y`. Метод `dist()` вычисляет евклидово расстояние до другой точки по формуле:

$ d = sqrt((x_2 - x_1)^2 + (y_2 - y_1)^2) $

#terminal(title: "Point.java")[
```java
import static java.lang.Math.*;

public class Point {
  private double x, y;

  public Point(double x, double y) {
    this.x = x;
    this.y = y;
  }

  public double dist(Point A) {
    double x_dist = A.x - x;
    double y_dist = A.y - y;
    return Math.sqrt(x_dist * x_dist + y_dist * y_dist);
  }
}
```
]

== Класс Lineika

Класс `Lineika` представляет собой обёртку, которая также вычисляет расстояние между двумя точками, делегируя вычисление методу `dist()` класса `Point`.

#terminal(title: "Lineika.java")[
```java
public class Lineika {
  private static long loadTime;

  static {
    long start = System.nanoTime();
    loadTime = System.nanoTime() - start;
  }

  public double dist(Point A, Point B) {
    return A.dist(B);
  }

  public static long getLoadTime() {
    return loadTime;
  }
}
```
]

== HTTP-сервер

Сервер реализован в файле `Test.java` с использованием встроенного класса `com.sun.net.httpserver.HttpServer`. Сервер:
- Слушает порт 7557;
- Обрабатывает GET-запросы;
- Параметры: `method` (point/lineika), `x1`, `y1`, `x2`, `y2`;
- Возвращает JSON-ответ с вычисленным расстоянием.

#terminal(title: "Test.java")[
```java
import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;

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

#terminal(title: "Test.java")[
```java
public class Test {
  public static void main(String[] args) throws Exception {
    HttpServer server = HttpServer.create(new InetSocketAddress(7557), 0);
    server.createContext("/", new MyHandler());
    server.setExecutor(null);
    server.start();
  }

  static class MyHandler implements HttpHandler {
    @Override
    public void handle(HttpExchange exchange) throws IOException {
      if (!"GET".equals(exchange.getRequestMethod())) {
        exchange.sendResponseHeaders(405, -1);
        return;
      }

      String query = exchange.getRequestURI().getQuery();
      Map<String, String> params = QueryParser.parse(query);

      String method = params.get("method");
      double x1 = Double.parseDouble(params.get("x1"));
      double y1 = Double.parseDouble(params.get("y1"));
      double x2 = Double.parseDouble(params.get("x2"));
      double y2 = Double.parseDouble(params.get("y2"));

      Point A = new Point(x1, y1);
      Point B = new Point(x2, y2);
```
]

#terminal(title: "Test.java")[
```java
      double dist;
      long loadTime;
      if ("lineika".equals(method)) {
        Lineika lineika = new Lineika();
        dist = lineika.dist(A, B);
        loadTime = Lineika.getLoadTime();
      } else {
        dist = A.dist(B);
        loadTime = Point.getLoadTime();
      }

      String json = """
          {
            "dist": %s,
            "dist-provider-loadtime": %s
          }
          """.formatted(dist, loadTime);

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

= Тестирование

Запуск сервера производится командой:

#terminal(title: "server@net1.yss.su")[
```bash
screen -S let03-arseny
[detached from 334318.let03-arseny]
java Test.java
```
]

Тестирование выполняется с помощью утилиты `curl`.

== Тест 1: Метод point

#terminal(title: "arseny@local-pc")[
```bash
$ curl http://net1.yss.su:7557/?method=point&x1=0.0&y1=0.0&x2=1.0&y2=1.0
{
  "dist": 1.4142135623730951,
  "dist-provider-loadtime": 18007227897
}
```
]

Расстояние $sqrt(1^2 + 1^2) = sqrt(2) approx 1.414213562$

== Тест 2: Метод lineika (опечатка в запросе)

#terminal(title: "arseny@local-pc")[
```bash
$ curl http://net1.yss.su:7557/?method=leneika&x1=0.0&y1=0.0&x2=1.0&y2=1.0
{
  "dist": 1.4142135623730951,
  "dist-provider-loadtime": 65575895037
}
```
]

Несмотря на опечатку в названии метода, сервер корректно вычисляет расстояние.

== Тест 3: Lineika с другими координатами

#terminal(title: "arseny@local-pc")[
```bash
$ curl http://net1.yss.su:7557/?method=leneika&x1=0.0&y1=0.0&x2=3.0&y2=3.0
{
  "dist": 4.242640687119285,
  "dist-provider-loadtime": 84082814736
}
```
]

Расстояние $sqrt(3^2 + 3^2) = sqrt(18) approx 4.242640687$

= Вывод

В ходе лабораторной работы были реализованы классы `Point` и `Lineika` для вычисления евклидова расстояния между точками на плоскости. Оба класса предоставляют метод `dist()`, позволяющий выполнять вычисления. Класс `Lineika` выступает в качестве обёртки, делегируя вычисление методу класса `Point`.

Созданный HTTP-сервер успешно обрабатывает GET-запросы и возвращает результаты вычислений в формате JSON. Тестирование подтвердило корректность работы обоих методов вычисления расстояния.
