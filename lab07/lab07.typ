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
  lab_number: "7",
  course: "Языки и методы программирования",
  theme: "GUI-чат на Java Swing и MQTT",
  year: "2026"
)

#outline()

= Цель работы

Разработать графический чат-клиент на Java с использованием библиотек Swing и Eclipse Paho MQTT. Приложение должно обеспечивать визуальный интерфейс для отправки и получения сообщений через MQTT-брокер.

*Задачи:*
- Изучить компоненты библиотеки Swing для создания GUI.
- Создать окно чата с полем ввода сообщений и списком доступных топиков.
- Реализовать подключение к MQTT-брокеру для отправки и получения сообщений.
- Использовать библиотеку FlatLaF для современного внешнего вида.


= Теоретические сведения

== Библиотека FlatLaF

FlatLaF — это библиотека для создания современного пользовательского интерфейса в Swing-приложениях. Она предоставляет различные темы оформления:

- `FlatDarkLaf` — тёмная тема
- `FlatMacLightLaf` — светлая тема в стиле macOS

== Архитектура приложения

Приложение ChatGUI состоит из следующих компонентов:
- Главное окно (JFrame)
- Панель настроек (топик, имя пользователя)
- Область сообщений (JTextArea)
- Панель ввода сообщений (JTextField, JButton)
- Список доступных топиков (JTextArea)


= Реализация приложения

== Класс ChatGUI

#terminal(title: "ChatGUI.java")[
```java
public class ChatGUI extends JFrame {
  private JTextField topicInput;
  private JTextField usernameInput;
  private JTextArea messagesArea;
  private JTextField messageInput;
  private JButton sendButton;
  private JTextArea topicsArea;

  private MqttClient client;
  private MqttClient topicClient;

  public ChatGUI() {
    setTitle("MQTT Chat");
    setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    setSize(600, 500);
    setLayout(new BorderLayout(10, 10));

    initComponents();
    connectToBroker();
  }
}
```
]

== Инициализация компонентов

#terminal(title: "ChatGUI.java")[
```java
private void initComponents() {
  JPanel topPanel = new JPanel(new BorderLayout(5, 5));
  topPanel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

  JPanel topicsPanel = new JPanel(new BorderLayout(5, 5));
  topicsPanel.add(new JLabel("Доступные топики:"), BorderLayout.NORTH);

  topicsArea = new JTextArea(3, 30);
  topicsArea.setEditable(false);
  topicsPanel.add(new JScrollPane(topicsArea), BorderLayout.CENTER);

  JPanel inputPanel = new JPanel(new GridLayout(2, 2, 5, 5));
  inputPanel.add(new JLabel("Топик:"));
  topicInput = new JTextField(currentTopic);
  inputPanel.add(topicInput);

  inputPanel.add(new JLabel("Имя:"));
  usernameInput = new JTextField("");
  inputPanel.add(usernameInput);

  topPanel.add(topicsPanel, BorderLayout.NORTH);
  topPanel.add(inputPanel, BorderLayout.CENTER);

  messagesArea = new JTextArea();
  messagesArea.setEditable(false);
  messagesArea.setLineWrap(true);
  messagesArea.setWrapStyleWord(true);
  JScrollPane messagesScroll = new JScrollPane(messagesArea);
  messagesScroll.setBorder(BorderFactory.createTitledBorder("Сообщения"));

  JPanel bottomPanel = new JPanel(new BorderLayout(5, 5));
  messageInput = new JTextField();
  messageInput.addActionListener(e -> sendMessage());

  sendButton = new JButton("Отправить");
  sendButton.addActionListener(e -> sendMessage());

  bottomPanel.add(messageInput, BorderLayout.CENTER);
  bottomPanel.add(sendButton, BorderLayout.EAST);

  add(topPanel, BorderLayout.NORTH);
  add(messagesScroll, BorderLayout.CENTER);
  add(bottomPanel, BorderLayout.SOUTH);
}
```
]

== Подключение к брокеру

#terminal(title: "ChatGUI.java")[
```java
private void connectToBroker() {
  String broker = "tcp://localhost:1883";

  try {
    client = new MqttClient(broker, clientId, new MemoryPersistence());
    client.setCallback(new MqttCallback() {
      @Override
      public void messageArrived(String topic, MqttMessage message) throws Exception {
        String msg = new String(message.getPayload());
        SwingUtilities.invokeLater(() -> {
          messagesArea.append(msg + "\n");
          messagesArea.setCaretPosition(messagesArea.getDocument().getLength());
        });
      }

      @Override
      public void deliveryComplete(IMqttDeliveryToken token) {
      }

      @Override
      public void connectionLost(Throwable cause) {
        SwingUtilities.invokeLater(() -> {
          JOptionPane.showMessageDialog(ChatGUI.this,
              "Соединение потеряно!", "Ошибка", JOptionPane.ERROR_MESSAGE);
        });
      }
    });

    client.connect();
    client.subscribe(currentTopic, 1);

    // второй клиент для отслеживания всех топиков
    topicClient = new MqttClient(broker, topicClientId, new MemoryPersistence());
    topicClient.setCallback(new MqttCallback() {
      @Override
      public void messageArrived(String topic, MqttMessage message) throws Exception {
        String msg = new String(message.getPayload());
        SwingUtilities.invokeLater(() -> {
          if (!allChats.contains(topic)) {
            allChats.add(topic);
            topicsArea.append(topic + "\n");
          }
        });
      }
      // ...
    });

    topicClient.connect();
    topicClient.subscribe("#", 1);
  } catch (MqttException e) {
    JOptionPane.showMessageDialog(this, "Ошибка подключения: " + e.getMessage());
  }
}
```
]

== Отправка сообщений

#terminal(title: "ChatGUI.java")[
```java
private void sendMessage() {
  String message = messageInput.getText().trim();
  if (message.isEmpty())
    return;

  String username = usernameInput.getText().trim();
  if (username.isEmpty()) {
    username = "User";
  }

  String newTopic = topicInput.getText().trim();
  boolean topicChanged = false;
  if (!newTopic.equals(currentTopic)) {
    try {
      if (client != null && client.isConnected()) {
        client.unsubscribe(currentTopic);
        client.subscribe(newTopic, 1);
        currentTopic = newTopic;
        topicChanged = true;
      }
    } catch (MqttException e) {
      JOptionPane.showMessageDialog(this, "Ошибка смены топика: " + e.getMessage());
    }
  }

  if (topicChanged) {
    messagesArea.setText("");
    appendMessage("=== Подключено к новому топику: " + currentTopic + " ===");
  }

  String timestamp = LocalDateTime.now().format(formatter);
  String fullMessage = "[" + timestamp + "] " + username + ": " + message;

  try {
    client.publish(currentTopic, new MqttMessage(fullMessage.getBytes()));
    messageInput.setText("");
  } catch (MqttException e) {
    JOptionPane.showMessageDialog(this, "Ошибка отправки: " + e.getMessage());
  }
}
```
]

== Главный метод

#terminal(title: "ChatGUI.java")[
```java
public static void main(String[] args) {
  SwingUtilities.invokeLater(() -> {
    try {
      UIManager.setLookAndFeel(new FlatDarkLaf());
    } catch (Exception e) {
      e.printStackTrace();
    }
    new ChatGUI().setVisible(true);
  });
}
```
]


= Сборка и запуск

== Используемые библиотеки

#terminal(title: "terminal")[
```bash
$ ls -la lib/
-rw-r--r-- 1 root ... flatlaf-3.7.jar
-rw-r--r-- 1 root ... org.eclipse.paho.client.mqttv3-1.2.5.jar
```
]

== Makefile

#terminal(title: "Makefile")[
```makefile
.PHONY: all clean run

all:
	javac -cp lib/flatlaf-3.7.jar:lib/org.eclipse.paho.client.mqttv3-1.2.5.jar \
		-d out src/ChatGUI.java

run:
	java -cp out:lib/flatlaf-3.7.jar:lib/org.eclipse.paho.client.mqttv3-1.2.5.jar \
		ChatGUI

clean:
	rm -f out/*.class
```
]

== Компиляция и запуск

#terminal(title: "terminal")[
```bash
$ make
$ make run
```
]

После запуска открывается окно чата с:
- Полем ввода топика
- Полем ввода имени пользователя
- Областью сообщений
- Полем ввода сообщения и кнопкой "Отправить"
- Списком доступных топиков


= Вывод

В ходе лабораторной работы был разработан GUI-чат на Java Swing с использованием протокола MQTT. Приложение ChatGUI обеспечивает:

- Графический интерфейс пользователя с использованием библиотеки FlatLaF
- Подключение к MQTT-брокеру для обмена сообщениями
- Возможность выбора топика для чата
- Отображение списка доступных топиков
- Добавление временной метки к сообщениям
- Автоматическую смену топика без переподключения

Использование Swing и MQTT позволяет создавать современные приложения для обмена сообщениями в реальном времени.