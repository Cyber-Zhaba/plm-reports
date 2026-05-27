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
  lab_number: "12",
  course: "Языки и методы программирования",
  theme: "FileExplorer. Сокеты и Swing GUI",
  year: "2026"
)

#outline()

= Цель работы

Разработать приложение для поиска ссылок в файлах с использованием ServerSocket и клиентского GUI-приложения на Swing. Сервер сканирует директорию, ищет ссылки формата [text](url) и возвращает их клиенту.

*Задачи:*
- Реализовать серверный FileExplorer для сканирования файлов.
- Обработать команду links для поиска ссылок.
- Создать клиентское GUI-приложение на Swing.


= Серверная часть

== Класс FileExplorer

Класс для работы с файловой системой:

#terminal(title: "server.cpp")[
```cpp
class FileExplorer {
  const char *path;
  DIR *dir;

public:
  FileExplorer(const char *path) : path(path), dir(opendir(path)) {}

  ~FileExplorer() { closedir(dir); }

  vector<string> ls() {
    struct dirent *entry;
    vector<string> result;
    while ((entry = readdir(dir)) != nullptr) {
      result.push_back(entry->d_name);
    }
    return result;
  }

  vector<string> contains(const vector<string> &list, const string &s) {
    vector<string> result;
    for (auto str : list)
      if (str.find(s) != string::npos)
        result.push_back(str);
    return result;
  }

  vector<string> cat(const vector<string> &list) {
    vector<string> result;
    for (auto filename : list) {
      filename = string(path) + "/" + filename;
      std::ifstream file(filename);
      std::string line;
      while (std::getline(file, line))
        result.push_back(line);
      file.close();
    }
    return result;
  }
};
```
]

Методы:
- ls() — список файлов в директории
- contains() — фильтрация по расширению
- cat() — чтение содержимого файлов


== Функция parse()

Поиск ссылок формата [text](url):

#terminal(title: "server.cpp")[
```cpp
void parse(const string &s, int *x, int *y) {
  for (size_t i = 0; i < s.size(); i++) {
    if (s.at(i) == '[') {
      for (size_t j = i; j < s.size(); j++) {
        if (s.at(j) == ']') {
          if (j + 1 < s.size() && s.at(j + 1) == '(') {
            for (size_t k = j; k < s.size(); k++) {
              if (s.at(k) == ')') {
                *x = i;
                *y = k - i + 1;
                return;
              }
            }
          }
        }
      }
    }
  }
  *x = -1;
  *y = -1;
}
```
]

Поиск осуществляется посимвольно:
- ищем [
- затем ]
- затем (
- затем )
- возвращаем позицию и длину ссылки


== Обработка команды links

#terminal(title: "server.cpp")[
```cpp
size_t cmd_pos = str.find("links");
if (cmd_pos != std::string::npos) {
  FileExplorer fe("src");

  vector<string> links;

  for (const auto &s : fe.cat(fe.contains(fe.ls(), ".md"))) {
    int i, j;
    parse(s, &i, &j);
    if (i != -1)
      links.push_back(s.substr(i, j));
  }

  std::string result;
  for (const auto &s : links) {
    result += s + "\n";
  }

  send(clientSocket, result.c_str(), result.size(), 0);
}
```
]

Сервер:
1. Принимает команду "links"
2. Сканирует директорию src
3. Читает все .md файлы
4. Ищет ссылки формата [text](url)
5. Возвращает список ссылок


== main()

#terminal(title: "server.cpp")[
```cpp
int main() {
  Socket s(3896, "0.0.0.0");
  s.bind_and_listen();
  std::cout << "[*] Server started ..." << std::endl;
  while (true) {
    s.wait_for_message();
  }
}
```
]


= Клиентская часть (Swing GUI)

== Класс Client

#terminal(title: "Client.java")[
```java
public class Client extends JFrame {
  private JTextField serverInput;
  private JTextField portInput;
  private JButton connectButton;
  private JTextArea responseArea;
  private JTextField messageInput;
  private JButton sendButton;

  private Socket socket;
  private PrintWriter out;
  private BufferedReader in;
}
```
]

Компоненты GUI:
- serverInput — адрес сервера
- portInput — порт сервера
- connectButton — кнопка подключения
- responseArea — область вывода ответов
- messageInput — поле ввода команды
- sendButton — кнопка отправки

== Подключение к серверу

#terminal(title: "Client.java")[
```java
private void connectToServer() {
  String server = serverInput.getText().trim();
  int port = Integer.parseInt(portInput.getText().trim());

  socket = new Socket(server, port);
  out = new PrintWriter(socket.getOutputStream(), true);
  in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

  connectButton.setText("Подключено");
  connectButton.setEnabled(false);
  responseArea.append("Подключено к " + server + ":" + port + "\n");
}
```
]

== Отправка сообщений

#terminal(title: "Client.java")[
```java
private void sendMessage() {
  String message = messageInput.getText();
  out.println(message);
  char[] buffer = new char[1024];
  int bytesRead = in.read(buffer);
  if (bytesRead > 0) {
    String response = new String(buffer, 0, bytesRead);
    responseArea.append("Сервер: " + response + "\n");
  }
  messageInput.setText("");
}
```
]

== main()

#terminal(title: "Client.java")[
```java
public static void main(String[] args) {
  SwingUtilities.invokeLater(() -> {
    try {
      UIManager.setLookAndFeel(new FlatDarkLaf());
    } catch (Exception ignored) {
    }
    new Client().setVisible(true);
  });
}
```
]


= Тестирование

== Запуск сервера

#terminal(title: "server@host")[
```bash
$ make
$ ./server
[*] Server started ...
```
]

== Запуск клиента

Пользователь вводит команду "links" и получает список ссылок из .md файлов.

#terminal(title: "client")[
```bash
links
[text](https://example.com)
[документация](doc.md)
```
]


= Вывод

В ходе лабораторной работы были реализованы:

1. **Сервер FileExplorer** — сканирование директорий и поиск ссылок в файлах
2. **Функция parse()** — поиск ссылок формата Markdown [text](url)
3. **Клиентский GUI на Swing** — удобный интерфейс для отправки команд
4. **FlatLaF** — современное оформление интерфейса

Сервер обрабатывает команду "links", сканирует .md файлы и возвращает найденные ссылки.