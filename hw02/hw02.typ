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
    #text(size: 18pt, weight: "bold")[Домашняя работа № #lab_number] \
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
  lab_number: "2",
  course: "Языки и методы программирования",
  theme: "MQTT. Publisher и Subscriber. Java Swing",
  year: "2026",
)

#outline()

= Цель работы

Разработать два Java-приложения с графическим интерфейсом: MQTT-издатель (Publisher) и MQTT-подписчик (Subscriber) с декодированием бинарных сообщений.

= Класс Publisher

Принимает текстовый ввод от пользователя и публикует сообщение в MQTT-топик `/IU9/Buldakov`.

- Графический интерфейс: текстовое поле ввода и кнопка `Send`.
- Подключение к брокеру `tcp://localhost:1883` через Eclipse Paho.
- Публикация строки как `MqttMessage`.
- Тёмная тема (FlatDarkLaf).

#terminal(title: "src/Publisher.java")[
```java
import com.formdev.flatlaf.FlatDarkLaf;
import org.eclipse.paho.client.mqttv3.*;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;
import javax.swing.*;
import java.awt.*;

public class Publisher extends JFrame {
  private JTextField inputField;
  private JButton sendButton;
  private MqttClient client;
  private final String TOPIC = "/IU9/Buldakov";

  public Publisher() {
    setTitle("Publisher");
    setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    setSize(300, 100);
    setLayout(new BorderLayout(5, 5));
    initComponents();
    connectToBroker();
  }

  private void initComponents() {
    inputField = new JTextField();
    inputField.addActionListener(e -> sendMessage());
    sendButton = new JButton("Send");
    sendButton.addActionListener(e -> sendMessage());
    add(inputField, BorderLayout.CENTER);
    add(sendButton, BorderLayout.EAST);
  }

  private void connectToBroker() {
    try {
      client = new MqttClient("tcp://localhost:1883",
          "Publisher_" + System.currentTimeMillis(),
          new MemoryPersistence());
      client.setCallback(new MqttCallback() {
        public void messageArrived(...) {}
        public void deliveryComplete(...) {}
        public void connectionLost(...) {}
      });
      client.connect();
    } catch (MqttException e) {}
  }

  private void sendMessage() {
    String input = inputField.getText().trim();
    if (input.isEmpty()) return;
    try {
      client.publish(TOPIC, new MqttMessage(input.getBytes()));
      inputField.setText("");
    } catch (MqttException e) {}
  }

  public static void main(String[] args) {
    SwingUtilities.invokeLater(() -> {
      try {
        UIManager.setLookAndFeel(new FlatDarkLaf());
      } catch (Exception e) {}
      new Publisher().setVisible(true);
    });
  }
}
```
]

= Класс Subscriber

Подписывается на топик `/IU9/Buldakov`, отображает историю сообщений и декодирует бинарные массивы в десятичные числа.

- Графический интерфейс: область истории сообщений и поле результата.
- Подписка с QoS 1.
- Декодирование сообщений вида `[1,0,1,1,...]` в целое число.

#terminal(title: "src/Subscriber.java — колбэк и декодирование")[
```java
client.setCallback(new MqttCallback() {
  public void messageArrived(String topic, MqttMessage msg) {
    String text = new String(msg.getPayload());
    String time = LocalTime.now()
        .format(DateTimeFormatter.ofPattern("HH:mm:ss"));
    historyArea.append("[" + time + "] " + text + "\n");
    resultField.setText(convertToDecimal(text));
  }
});

private String convertToDecimal(String bin) {
  bin = bin.replaceAll("[\\[\\] ]", "");
  String[] bits = bin.split(",");
  int result = 0;
  for (String bit : bits) {
    result = (result << 1) | Integer.parseInt(bit.trim());
  }
  return String.valueOf(result);
}
```
]

= Сборка и запуск

#terminal(title: "Makefile")[
```makefile
build:
	javac -cp "lib/flatlaf-3.7.jar:lib/org.eclipse.paho.client.mqttv3-1.2.5.jar" \
	  src/*.java -d out

run: build
	java -cp "out:lib/flatlaf-3.7.jar:lib/org.eclipse.paho.client.mqttv3-1.2.5.jar" \
	  Publisher &
	java -cp "out:lib/flatlaf-3.7.jar:lib/org.eclipse.paho.client.mqttv3-1.2.5.jar" \
	  Subscriber
```
]

#terminal(title: "Терминал")[
```bash
# Запустить MQTT-брокер
mosquitto -d

# Собрать и запустить приложения
cd hw02
make run
```
]

После запуска откроются два окна Swing:
- **Publisher** — ввод текста, отправка в топик `/IU9/Buldakov`;
- **Subscriber** — приём и отображение сообщений, декодирование бинарных массивов.

= Вывод

Разработаны два Java-приложения с графическим интерфейсом (Swing + FlatDarkLaf), использующие протокол MQTT для обмена сообщениями через брокер Mosquitto. Publisher отправляет текст в топик `/IU9/Buldakov`, Subscriber принимает сообщения, отображает их с меткой времени и преобразует бинарные массивы в десятичные числа. Работа приложений протестирована с локальным Mosquitto-брокером.
