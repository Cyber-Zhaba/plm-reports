// ============================================
// ШАБЛОН ТИТУЛЬНОЙ СТРАНИЦЫ МГТУ им. Н.Э. Баумана
// ============================================
// Это отдельный файл с функцией шаблона

// ============================================
// ГЛАВНАЯ ФУНКЦИЯ ШАБЛОНА
// ============================================
#let bauman-title-page(
  lab-number: "1",
  course: "Методы оптимизации",
  topic: "Поиск минимума функции",
  group: "ИУ9-82Б",
  student: "Фамилия И. О.",
  teacher: "Посевин Д. П.",
  year: "2024",
) = {
  // Настройка страницы
  set page(
    paper: "a4",
    margin: (
      top: 2cm,
      bottom: 2cm,
      left: 3cm,
      right: 1cm,
    ),
  )
  
  // Полуторный интервал
  set par(leading: 0.65em)
  
  // --- ШАПКА УНИВЕРСИТЕТА ---
  grid(
    columns: (3.5cm, 1fr),
    gutter: 1cm,
    
    align(center, image("images/emblem.png", width: 3cm)),
    
    align(center)[
      #set text(size: 10pt, weight: "bold")
      #v(-0.5em)
      Министерство науки и высшего образования Российской Федерации
      
      #v(-0.3em)
      Федеральное государственное бюджетное образовательное учреждение
      
      #v(-0.3em)
      высшего образования
      
      #v(-0.3em)
      <<Московский государственный технический университет
      
      #v(-0.3em)
      имени Н.Э. Баумана
      
      #v(-0.3em)
      (национальный исследовательский университет)>>
      
      #v(-0.3em)
      (МГТУ им. Н.Э. Баумана)
    ]
  )
  
  // Полосы
  v(-0.5cm)
  line(length: 100%, stroke: 2.3pt)
  v(-0.6cm)
  line(length: 100%, stroke: 0.4pt)
  
  // Факультет
  v(0.5cm)
  text(size: 10pt)[
    ФАКУЛЬТЕТ #h(3cm) <<Информатика и системы управления>>
  ]
  v(-0.4cm)
  h(2.8cm)
  line(length: 83%, stroke: 0.4pt)
  
  // Кафедра
  v(0.3cm)
  text(size: 10pt)[
    КАФЕДРА #h(1.5cm) <<Теоретическая информатика и компьютерные технологии>>
  ]
  v(-0.4cm)
  h(2.2cm)
  line(length: 86%, stroke: 0.4pt)
  
  // --- ЦЕНТР ---
  v(6cm)
  
  align(center)[
    #text(size: 16pt, weight: "bold")[
      Лабораторная работа № #lab-number
    ]
    
    #v(0.3cm)
    #text(size: 14pt, weight: "bold")[
      по курсу <<#course>>
    ]
    
    #v(0.3cm)
    #text(size: 14pt)[
      <<#topic>>
    ]
  ]
  
  // --- НИЗ ---
  v(4cm)
  
  align(right)[
    #text(size: 12pt)[
      Студент группы #group #student \
      #v(0.5cm)
      Преподаватель #teacher
    ]
  ]
  
  v(1fr)
  
  align(center)[
    #text(style: "italic")[
      Москва #year
    ]
  ]
}

// Вспомогательные функции
#let section(name) = {
  v(0.5cm)
  text(size: 14pt, weight: "bold")[#name]
  v(0.3cm)
}
