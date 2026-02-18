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
  lab_number: "1",
  course: "Языки и методы программирования",
  theme: "Установка среды IntelliJ IDEA",
  year: "2026"
)

#outline()

= Цель работы

Целью данной работы является установка и настройка интегрированной среды разработки IntelliJ IDEA для работы с языком программирования Java.

= Установка IntelliJ IDEA


== Процесс установки

1. Загрузка установочного файла с официального сайта JetBrains.
2. Запуск установщика и следование инструкциям мастера установки.
3. Выбор компонентов для установки (включая ассоциации файлов).
4. Завершение установки и первый запуск IDE.

#figure(
  image("idea.png", width: 80%),
  caption: [Скриншот установленной IDE IntelliJ IDEA]
)

= Настройка конфигурации запуска

После установки IntelliJ IDEA была выполнена настройка конфигурации запуска для Java-приложения. Конфигурация запуска позволяет задать параметры выполнения программы, включая:

- Основной класс для запуска
- Параметры JVM
- Аргументы командной строки
- Рабочую директорию

#figure(
  image("setup.png", width: 80%),
  caption: [Настройка конфигурации запуска в IntelliJ IDEA]
)

= Тестирование сервера внутри IDE

Для проверки работоспособности установленной среды разработки было выполнено тестирование простого HTTP-сервера непосредственно внутри IntelliJ IDEA.

Запуск сервера осуществлялся через встроенные инструменты IDE с использованием настроенной конфигурации запуска. В ходе тестирования был успешно запущен сервер на локальном порту.

#figure(
  image("test.png", width: 80%),
  caption: [Тестирование сервера внутри IntelliJ IDEA]
)

= Вывод

В ходе выполнения лабораторной работы была успешно установлена интегрированная среда разработки IntelliJ IDEA Community Edition. Выполнена настройка конфигурации запуска для Java-приложений, что позволяет запускать и отлаживать программы непосредственно из IDE.

