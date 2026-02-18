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
  // Настройки цветов
  let bg_color = luma(250)   // Очень светло-серый фон
  let border_color = luma(200) // Тонкая серая рамка
  let title_bg = luma(240)   // Фон заголовка чуть темнее

  // Формируем заголовок (если он есть)
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

  // Формируем тело с кодом
  let body = block(
    width: 100%,
    fill: bg_color,
    inset: 10pt,
    radius: if title != none { (bottom: 3pt) } else { 3pt },
    text(font: ("Fira Code", "Courier New"), size: 10pt, content)
  )

  // Объединяем в рамку
  block(
    width: 100%,
    stroke: 0.5pt + border_color,
    radius: 3pt,
    clip: true, // Обрезаем содержимое по радиусу
    breakable: false, // Стараемся не разрывать блок между страницами
    stack(dir: ttb, header, body)
  )
}

// ==========================================
// ИСПОЛЬЗОВАНИЕ
// ==========================================

#title_page(
  student: "Булдаков А. С.",
  group: "ИУ9-22Б",
  teacher: "Посевин Д. П.",
  lab_number: "1",
  course: "Языки и методы программирования",
  theme: "Установка Java на VDS сервер",
  year: "2026"
)

#outline()
// ============================================
// ТЕЛО ОТЧЕТА
// ============================================

= Цель работы

Настройка окружения на удаленном VDS сервере для разработки на Java.

*Задачи:*
- Создать собственную учетную запись на VDS сервере и настроить командную оболочку (bash/fish).
- Установить Java (JDK 25).
- Скомпилировать и запустить две версии веб-сервера.
- Выполнить индивидуальные задания по вариантам.

= Создание учётной записи

Первым шагом выполняется подключение к серверу под суперпользователем `root` для начальной настройки системы.

#terminal(title: "root@net1.yss.su")[
```bash
ssh root@net1.yss.su
```
]

Далее создается новый пользователь `arseny` без домашней директории (без ключа `-m`), затем директория создается вручную от имени root и передается в ownership пользователю. Команда `usermod` добавляет пользователя в группу `sudo` для выполнения административных задач.

#terminal(title: "root@net1.yss.su")[
```bash
# Создание пользователя без домашней директории
useradd arseny

# Создание домашней директории /home/arseny вручную от имени root
mkdir /home/arseny
chown arseny:arseny /home/arseny

# Назначение пароля
passwd arseny

# Добавление прав sudo
usermod -aG sudo arseny
```
]

= Настройка окружения и оболочки

В качестве основной командной оболочки был выбран *Fish* (Friendly Interactive SHell) из-за встроенной подсветки синтаксиса и удобных автодополнений.

Устанавливаем пакет и меняем оболочку по умолчанию:

#terminal(title: "root@net1.yss.su")[
```bash
apt update && apt install fish -y
su arseny
chsh -s /usr/bin/fish
```
]

Для удобства работы были настроены алиасы (псевдонимы команд) и переменные окружения.

*Конфигурация Fish (`~/.config/fish/config.fish`):*
#terminal(title: "nano ~/.config/fish/config.fish")[
```fish
# Улучшенный ls через eza
alias ls 'eza -lh --group-directories-first --icons=auto'
alias lt 'eza --tree --level=2 --long --icons --git'
alias .. 'cd ..'

# Переменные окружения Java
set -x JAVA_HOME $HOME/jdk-25.0.2
set -x PATH $JAVA_HOME/bin:$PATH
```
]

Также, для совместимости с классическими скриптами, были обновлены конфигурации Bash.

*Конфигурация Bash (`~/.bashrc`):*
#terminal(title: "nano ~/.bashrc")[
```bash
alias ls='eza -lh --group-directories-first --icons=auto'
alias la='ls -a'
alias ..='cd ..'

export JAVA_HOME=$HOME/jdk-25.0.2
export PATH=$JAVA_HOME/bin:$PATH
```
]

= Установка Java

Скачивание архива с Oracle OpenJDK 25 и распаковка в домашнюю директорию.

#terminal(title: "arseny@net1.yss.su")[
```bash
# Скачивание дистрибутива
wget https://download.oracle.com/java/25/latest/jdk-25_linux-x64_bin.tar.gz

# Распаковка
tar xzf jdk-25_linux-x64_bin.tar.gz

# Перемещение в корневую директорию пользователя
mv jdk-25.0.2/ ~/
```
]

Проверка версии после настройки переменных окружения (`PATH`):

#terminal[
```bash
java --version
# java 25.0.2 2025-01-21
# Java(TM) SE Runtime Environment (build 25.0.2+1-1)
# Java HotSpot(TM) 64-Bit Server VM (build 25.0.2+1-1, mixed mode, sharing)
```
]

= Компиляция и запуск программ

Для демонстрации работы Java была подготовлена следующая структура файлов на сервере:

#terminal(title: "File Structure")[
```text
.
├── dog
│   ├── Dog.class
│   └── Dog.java
├── factorial
│   ├── Factorial.class
│   └── Factorial.java
├── httpserver
│   ├── HttpServer.class
│   └── HttpServer.java
├── server-with-get-params
│   └── Test.java
└── testserver
    ├── Test$MyHandler.class
    ├── Test.class
    └── Test.java
```
]

== Базовые классы

Проверка работы простого класса `Dog` (создание объектов):

#terminal[
```bash
$ java dog/Dog.java

Dog is created!
Dog is created!
Age=0
Age=10
Age=105
Age method=105
```
]

Вычисление факториала числа 12 (программа принимает аргумент командной строки):

#terminal[
```bash
$ java factorial/Factorial.java 12

479001600
```
]

== Веб-сервер № 1

Запуск простейшего HTTP-сервера. Сервер слушает порт и выводит информацию о подключении.

#terminal(title: "server@net1.yss.su")[
```bash
$ java httpserver/HttpServer.java
Server started!
```
]

Клиентский запрос с локального компьютера:

#terminal(title: "arseny@local-pc")[
```bash
curl http://net1.yss.su:8079
```
]

Протокол взаимодействия (вывод на сервере):
#terminal(title: "server@net1.yss.su")[
```
Client connected!

GET / HTTP/1.1
Host: net1.yss.su:8079
User-Agent: curl/8.18.0
Accept: */*

Client disconnected!
```
]

== Веб-сервер № 2

Реализация сервера, который парсит GET-запросы и возвращает JSON-ответ.

#terminal(title: "server@net1.yss.su")[
```bash
java server-with-get-params/Test.java
```
]

Клиентский запрос с параметрами `name` и `age`:

#terminal(title: "arseny@local-pc")[
```bash
curl "http://net1.yss.su:7999/test?name=bob&age=42"
```
]

Ответ сервера (протокол взаимодействия):
#terminal(title: "server@net1.yss.su")[
```json
{
  "name": "bob",
  "age": 42,
  "objectId": "1fea06eb"
}
```
]

= Вывод

В ходе лабораторной работы был настроен VDS сервер под управлением Linux. Была создана учетная запись пользователя, настроена удобная оболочка Fish с алиасами и установлена Java 25. На практических примерах продемонстрирована работа с компиляцией Java-классов и созданием HTTP-серверов, обрабатывающих входящие запросы.
