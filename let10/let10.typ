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
  lab_number: "10",
  course: "Языки и методы программирования",
  theme: "TCP-клиент с GUI и обработкой исключений",
  year: "2026",
)

#outline()

= Цель работы

Разработать TCP-клиент с графическим интерфейсом на Swing и обработкой исключений. Реализовать механизм переподключения (reconnect) и протокол handshake.

*Задачи:*
- Реализовать GUI-клиент на Swing.
- Обработать исключения при подключении.
- Реализовать handshake между клиентом и сервером.
- Добавить автоматическое переподключение.


= Класс ConnectionHandler

Класс для управления TCP-соединением.

== Интерфейс NetworkListener

#terminal(title: "Client.java")[
  ```java
  class ConnectionHandler {
    private static final String DEFAULT_HOST = "185.104.251.226";
    private static final int DEFAULT_PORT = 3896;

    public interface NetworkListener {
      void onMessage(String msg);
      void onLog(String symbol, String msg);
      void onReady();
    }

    private Socket socket;
    private PrintWriter out;
    private BufferedReader in;
    private NetworkListener listener;
  }
  ```
]

Интерфейс NetworkListener обеспечивает обратный вызов для событий сети.

== Метод connect()

#terminal(title: "Client.java")[
  ```java
  public void connect(String host, int port) {
    new Thread(() -> {
      try {
        attempt(host, port);
      } catch (ConnectionException e) {
        listener.onLog("/!\\", "Ошибка: " + e.getMessage() + ". Реконект к дефолту...");
        try {
          attempt(DEFAULT_HOST, DEFAULT_PORT);
        } catch (ConnectionException ex) {
          listener.onLog("[!]", "Фатальная ошибка: " + ex.getMessage());
        }
      }
    }).start();
  }
  ```
]

Метод connect() запускает подключение в отдельном потоке и при ошибке выполняет переподключение к хосту по умолчанию.

== Handshake

#terminal(title: "Client.java")[
  ```java
  private void attempt(String host, int port) throws ConnectionException {
    listener.onLog("[*]", "Подключение к " + host + ":" + port);
    try {
      socket = new Socket();
      socket.connect(new InetSocketAddress(host, port), 3000);

      out = new PrintWriter(new BufferedWriter(new OutputStreamWriter(socket.getOutputStream())), true);
      in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

      out.println("SYN");
      String synAck = in.readLine();
      if (synAck != null && synAck.contains("SYN-ACK")) {
        listener.onLog("[+]", "Handshake успешен");
        listener.onReady();
        startListening();
      } else {
        throw new HandshakeException("Handshake failed: " + synAck);
      }
    } catch (IOException e) {
      throw new ConnectionException("Не удалось подключиться к " + host + ":" + port, e);
    }
  }
  ```
]

Протокол handshake:
1. Клиент отправляет SYN
2. Сервер отвечает SYN-ACK
3. При успехе запускается прослушивание
4. При ошибке — исключение


= Исключения

== Базовый класс ConnectionException

#terminal(title: "ConnectionException.java")[
  ```java
  public class ConnectionException extends Exception {
    public ConnectionException(String message) {
      super(message);
    }

    public ConnectionException(String message, Throwable cause) {
      super(message, cause);
    }
  }
  ```
]

== HandshakeException

#terminal(title: "HandshakeException.java")[
  ```java
  public class HandshakeException extends ConnectionException {
    public HandshakeException(String message) {
      super(message);
    }
  }
  ```
]

== ConnectionLostException

#terminal(title: "ConnectionLostException.java")[
  ```java
  public class ConnectionLostException extends RuntimeException {
    public ConnectionLostException(String message) {
      super(message);
    }
  }
  ```
]


= Прослушивание сообщений

#terminal(title: "Client.java")[
  ```java
  private void startListening() {
    new Thread(() -> {
      try {
        String line;
        while ((line = in.readLine()) != null) {
          if (line.equals("FLOW_STOPPED")) {
            listener.onLog("/!\\", "Сервер остановил поток. Перезапуск flow...");
            sendFlowCommand();
          } else {
            listener.onMessage(line);
          }
        }
      } catch (IOException e) {
        listener.onLog("[!]", "Связь разорвана: " + e.getMessage());
      }
    }).start();
  }
  ```
]

Метод startListening() в отдельном потоке ожидает сообщения от сервера. При получении FLOW_STOPPED автоматически отправляется команда flow.


= GUI-клиент

#terminal(title: "Client.java")[
  ```java
  public class Client extends JFrame implements ConnectionHandler.NetworkListener {
    private JTextField serverInput, portInput, messageInput;
    private JTextArea logArea;
    private JButton connectButton, sendButton;
    private ConnectionHandler handler;

    public Client() {
      setTitle("TCP Flow Client");
      setDefaultCloseOperation(EXIT_ON_CLOSE);
      setSize(500, 500);
      handler = new ConnectionHandler(this);
      initComponents();
    }

    private void initComponents() {
      JPanel top = new JPanel(new GridLayout(1, 5, 5, 5));
      serverInput = new JTextField("185.104.251.226");
      portInput = new JTextField("3896");
      connectButton = new JButton("Connect");
      connectButton.addActionListener(e -> handler.connect(...));

      logArea = new JTextArea();
      logArea.setEditable(false);
      logArea.setBackground(new Color(30, 30, 30));
      logArea.setForeground(new Color(200, 200, 200));

      messageInput = new JTextField();
      sendButton = new JButton("Send");
      sendButton.addActionListener(e -> {
        if (messageInput.getText().equals("flow"))
          handler.sendFlowCommand();
        else
          handler.sendMessage(messageInput.getText());
        messageInput.setText("");
      });
    }

    @Override
    public void onLog(String symbol, String msg) {
      SwingUtilities.invokeLater(() -> {
        logArea.append(symbol + " " + msg + "\n");
        logArea.setCaretPosition(logArea.getDocument().getLength());
      });
    }

    @Override
    public void onMessage(String msg) {
      SwingUtilities.invokeLater(() -> {
        logArea.append(" > " + msg + "\n");
      });
    }
  }
  ```
]

Компоненты GUI:
- serverInput — поле ввода IP-адреса
- portInput — поле ввода порта
- connectButton — кнопка подключения
- logArea — область вывода сообщений
- messageInput — поле ввода сообщения
- sendButton — кнопка отправки

== Темная тема (FlatLaF)

#terminal(title: "Client.java")[
  ```java
  public static void main(String[] args) {
    FlatDarkLaf.setup();
    SwingUtilities.invokeLater(() -> new Client().setVisible(true));
  }
  ```
]

Используется FlatDarkLaf для современного темного оформления.


= Вывод

В ходе лабораторной работы были реализованы:

1. **ConnectionHandler** — класс управления соединением с переподключением
2. **Handshake** — протокол синхронизации между клиентом и сервером
3. **Исключения** — ConnectionException, HandshakeException, ConnectionLostException
4. **GUI на Swing** — клиент с темной темой
5. **Многопоточность** — connect и listen в отдельных потоках

Клиент автоматически обрабатывает разрыв соединения и выполняет переподключение.

