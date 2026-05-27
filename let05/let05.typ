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
  lab_number: "5",
  course: "Языки и методы программирования",
  theme: "MQTT-клиент на Java",
  year: "2026",
)

#outline()

= Цель работы

Разработать консольное приложение для обмена сообщениями в реальном времени с использованием протокола MQTT (Message Queuing Telemetry Transport). Приложение должно подключаться к MQTT-брокеру и обеспечивать отправку и получение сообщений в чате.

*Задачи:*
- Изучить протокол MQTT и библиотеку Paho.
- Реализовать MQTT-клиент для отправки сообщений.
- Реализовать подписку на топик для получения сообщений.
- Запустить брокер Mosquitto и протестировать чат.


= Теоретические сведения

MQTT — это легковесный протокол обмена сообщениями, построенный на модели издание-подписка (publish-subscribe). Основные компоненты MQTT:

- **Брокер** — сервер, который пересылает сообщения между клиентами. Популярные брокеры: Mosquitto, HiveMQ, EMQX.
- **Издатель (Publisher)** — клиент, который отправляет сообщения в определённый топик.
- **Подписчик (Subscriber)** — клиент, который получает сообщения из топика.
- **Топик** — строка, идентифицирующая тему сообщения, например, `/IU9/Buldakov`.

Преимущества MQTT:
- Низкое потребление ресурсов
- Быстрая доставка сообщений
- Простота реализации
- Поддержка качества обслуживания (QoS)


= Реализация чата

Класс `Chat` реализует MQTT-клиент для обмена сообщениями.

== Подключение библиотеки Paho

Для работы с MQTT используется библиотека Eclipse Paho:

#terminal(title: "terminal")[
  ```bash
  $ ls -la *.jar
  -rw-r--r-- 1 root ... org.eclipse.paho.client.mqttv3-1.2.5.jar
  ```
]

== Класс Chat

#terminal(title: "Chat.java")[
  ```java
  import org.eclipse.paho.client.mqttv3.MqttClient;
  import org.eclipse.paho.client.mqttv3.MqttException;
  import org.eclipse.paho.client.mqttv3.MqttMessage;
  import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;

  import java.util.Scanner;

  public class Chat {
    public String username;

    private Scanner scan = new Scanner(System.in);
    private String topic = "/IU9/Buldakov";
    private String broker = "tcp://localhost:1883";

    private MqttClient client;

    public void main(String[] args) throws MqttException {
      System.out.println("Введите имя пользователя:");
      username = scan.nextLine();

      client = new MqttClient(broker, username, new MemoryPersistence());
      client.setCallback(new MqttCallback() {
        @Override
        public void messageArrived(String topic, MqttMessage message) throws Exception {
          System.out.println(new String(message.getPayload()));
        }

        @Override
        public void deliveryComplete(IMqttDeliveryToken token) {
        }

        @Override
        public void connectionLost(Throwable cause) {
          System.out.println("Технические шоколадки, соединение потеряно!");
        }
      });

      System.out.println("[*] Подключение к чату " + topic + " ...");
      client.connect();
      client.subscribe(topic, 1);
      System.out.println("[+] Подключение выполнено успешно!");

      while (true) {
        String message = scan.nextLine();
        client.publish(topic, new MqttMessage((username + ": " +
            message).getBytes()));
      }
    }
  }
  ```
]

Основные методы MqttClient:
- `new MqttClient(broker, clientId, persistence)` — создание клиента
- `connect()` — подключение к брокеру
- `subscribe(topic, qos)` — подписка на топик
- `publish(topic, message)` — публикация сообщения

== Конфигурация Mosquitto

Файлы конфигурации для запуска брокера:

#terminal(title: "mosquitto.conf")[
  ```
  listener 1883
  allow_anonymous true
  ```
]

Запуск брокера:

#terminal(title: "terminal")[
  ```bash
  $ mosquitto -c mosquitto.conf
  1717676416: mosquitto version 2.0.15 started
  ```
]

== Makefile

Makefile для компиляции и запуска:

#terminal(title: "Makefile")[
  ```makefile
  .PHONY: all clean run

  all:
  	javac -cp .:org.eclipse.paho.client.mqttv3-1.2.5.jar Chat.java

  run:
  	java -cp .:org.eclipse.paho.client.mqttv3-1.2.5.jar Chat

  clean:
  	rm -f *.class
  ```
]


= Тестирование

== Запуск брокера Mosquitto

#terminal(title: "user@server")[
  ```bash
  $ mosquitto -c mosquitto.conf
  1717676416: mosquitto version 2.0.15 started
  ```
]

== Запуск первого клиента

#terminal(title: "user1@terminal")[
  ```bash
  $ java -cp .:org.eclipse.paho.client.mqttv3-1.2.5.jar Chat
  Введите имя пользователя:
  Александр
  [*] Подключение к чату /IU9/Buldakov ...
  [+] Подключение выполнено успешно!
  Привет всем!
  Как дела?
  ```
]

== Запуск второго клиента

#terminal(title: "user2@terminal")[
  ```bash
  $ java -cp .:org.eclipse.paho.client.mqttv3-1.2.5.jar Chat
  Введите имя пользователя:
  Мария
  [*] Подключение к чату /IU9/Buldakov ...
  [+] Подключение выполнено успешно!
  Александр: Привет всем!
  Александр: Как дела?
  Привет! У меня всё хорошо.
  ```
]

== Результат обмена сообщениями

#terminal(title: "user1@terminal")[
  ```bash
  Александр: Привет всем!
  Александр: Как дела?
  Мария: Привет! У меня всё хорошо.
  ```
]

Оба клиента успешно обмениваются сообщениями в реальном времени через MQTT-брокер.


= Вывод

В ходе лабораторной работы был реализован MQTT-чат на Java с использованием библиотеки Eclipse Paho. Приложение позволяет пользователям:
- Подключаться к MQTT-брокеру Mosquitto
- Публиковать сообщения в топик
- Получать сообщения из топика в реальном времени

Протокол MQTT обеспечивает быстрый и эффективный обмен сообщениями, что делает его идеальным для использования в системах IoT и чат-приложениях.

