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
  theme: "Сокеты в C++. TCP-сервер и клиент",
  year: "2026"
)

#outline()

= Цель работы

Реализовать TCP-сервер и клиент на C++ с использованием сокетов. Сервер принимает сообщения от клиентов и отправляет их обратно (режим ECHO).

*Задачи:*
- Изучить API сокетов в C++.
- Реализовать класс Socket для работы с TCP.
- Создать сервер с функцией accept и recv/send.
- Создать клиент с функцией connect.


= Теоретические сведения

Сокеты — это программный интерфейс для межпроцессного взаимодействия. Основные функции:
- socket() — создание сокета
- bind() — привязка к адресу и порту
- listen() — прослушивание порта
- accept() — принятие соединения
- connect() — подключение к серверу
- send() — отправка данных
- recv() — получение данных


= Реализация класса Socket

Класс Socket инкапсулирует работу с TCP-сокетами.

== Заголовочный файл socket.hpp

#terminal(title: "socket.hpp")[
```cpp
#include <arpa/inet.h>
#include <cstring>
#include <iostream>
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>

struct Socket {
  int serverSocket;
  sockaddr_in serverAddress;
  int port;
  const char *target_ip;

  Socket(int port, const char *target_ip) : port(port), target_ip(target_ip) {
    serverSocket = socket(AF_INET, SOCK_STREAM, 0);

    serverAddress.sin_family = AF_INET;
    serverAddress.sin_port = htons(port);

    inet_pton(AF_INET, target_ip, &serverAddress.sin_addr);
  }

  ~Socket() { close(serverSocket); }
};
```
]

== Конструктор

В конструкторе создается сокет и инициализируется адрес:
- socket(AF_INET, SOCK_STREAM, 0) — создание TCP-сокета
- htons(port) — преобразование порта в сетевой порядок байтов
- inet_pton() — преобразование IP-адреса из текстового в бинарный формат


= Серверная часть

== bind_and_listen()

#terminal(title: "socket.hpp")[
```cpp
void bind_and_listen() {
  bind(serverSocket, (struct sockaddr *)&serverAddress,
       sizeof(serverAddress));
  listen(serverSocket, 5);
}
```
]

- bind() — привязка сокета к адресу и порту
- listen() — перевод сокета в режим прослушивания (очередь 5 клиентов)

== wait_for_message()

#terminal(title: "socket.hpp")[
```cpp
void wait_for_message() {
  sockaddr_in client_addr;
  socklen_t addr_len = sizeof(client_addr);

  int clientSocket =
      accept(serverSocket, (struct sockaddr *)&client_addr, &addr_len);

  char client_ip[INET_ADDRSTRLEN];
  inet_ntop(AF_INET, &client_addr.sin_addr, client_ip, INET_ADDRSTRLEN);

  char buffer[1024];
  while (true) {
    memset(buffer, 0, 1024);
    int bytesRead = recv(clientSocket, buffer, sizeof(buffer), 0);

    std::cout << "Received: " << buffer << std::endl;
    std::cout << "Sended back: " << buffer << std::endl;

    // ECHO: отправляем обратно
    send(clientSocket, buffer, bytesRead, 0);
  }
  close(clientSocket);
}
```
]

- accept() — принятие соединения от клиента
- recv() — получение данных от клиента
- send() — отправка данных клиенту (режим ECHO)
- inet_ntop() — преобразование IP-адреса в текстовый формат


= Клиентская часть

== connect_to_server()

#terminal(title: "socket.hpp")[
```cpp
void connect_to_server() {
  connect(serverSocket, (struct sockaddr *)&serverAddress,
          sizeof(serverAddress));
}
```
]

== send_message()

#terminal(title: "socket.hpp")[
```cpp
void send_message(const char *message) {
  send(serverSocket, message, strlen(message), 0);
  char buffer[1024] = {0};
  int bytesRead = recv(serverSocket, buffer, sizeof(buffer), 0);
  if (bytesRead > 0) {
    std::cout << "Received from server: " << buffer << std::endl;
  }
}
```
]


= main()

== Сервер

#terminal(title: "server.cpp")[
```cpp
int main() {
  Socket s(3896, "185.104.251.226");

  s.bind_and_listen();
  while (true) {
    s.wait_for_message();
  }
}
```
]

== Клиент

#terminal(title: "client.cpp")[
```cpp
int main() {
  Socket s(3896, "185.104.251.226");

  s.connect_to_server();

  std::string line;
  while (std::getline(std::cin, line)) {
    s.send_message(line.c_str());
  }
}
```
]


= Компиляция и запуск

== Makefile

#terminal(title: "Makefile")[
```makefile
.PHONY: all run clean

all:
	g++ -o build/server server.cpp
	g++ -o build/client client.cpp

run_server: all
	./build/server

run_client: all
	./build/client

clean:
	rm -rf build
```
]

== Запуск

#terminal(title: "server@host")[
```bash
$ make run_server &
```
]

#terminal(title: "client@local")[
```bash
$ make run_client
Hello, server!
Received from server: Hello, server!
```
]

Сервер получает сообщение и отправляет его обратно (режим ECHO).


= Ключевые понятия

1. **socket()** — создание сокета
2. **bind()** — привязка к порту
3. **listen()** — прослушивание
4. **accept()** — принятие соединения
5. **connect()** — подключение к серверу
6. **send()/recv()** — отправка и получение данных
7. **htons()/inet_pton()** — преобразование адресов


= Вывод

В ходе лабораторной работы были реализованы:

1. Класс Socket для работы с TCP-сокетами
2. TCP-сервер, принимающий соединения и отправляющий данные обратно (ECHO)
3. TCP-клиент для отправки сообщений серверу

Использованы системные вызовы socket API в C++ для сетевого взаимодействия.