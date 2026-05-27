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
  lab_number: "6",
  course: "Языки и методы программирования",
  theme: "Графические приложения на Java Swing",
  year: "2026"
)

#outline()

= Цель работы

Разработать графические приложения на Java с использованием библиотеки Swing. Создать приложение для рисования геометрических фигур (окружностей и квадратов) и 3D-модель кубика Рубика с возможностью вращения.

*Задачи:*
- Изучить основы библиотеки Swing.
- Создать приложение PictureForm с настраиваемыми параметрами рисования.
- Разработать приложение RubiksCubeApp с 3D-визуализацией кубика.
- Реализовать вращение 3D-модели вокруг осей X, Y, Z.


= Приложение PictureForm

Приложение PictureForm представляет собой графическую программу для отображения окружности с расположенными вокруг неё квадратами. Параметры фигур можно изменять в реальном времени с помощью элементов управления.

== Структура приложения

Приложение состоит из двух классов:
- `PictureForm` — главный класс с управляющими элементами (Spinner, JColorChooser)
- `CanvasPanel` — панель для рисования

== Класс CanvasPanel

Класс `CanvasPanel` наследуется от `JPanel` и переопределяет метод `paintComponent()` для отрисовки графики.

#terminal(title: "CanvasPanel.java")[
```java
class CanvasPanel extends JPanel {
    private int radius = 20;
    private int side = 20;
    private Color squareColor = Color.RED;
    private Color circleColor = Color.GREEN;

    protected void paintComponent(Graphics g) {
        super.paintComponent(g);

        Graphics2D g2d = (Graphics2D) g;

        int centerX = getWidth() / 2;
        int centerY = getHeight() / 2;

        int numSquares = (int) Math.floor(2.0 * Math.PI * radius / side);

        g2d.setColor(circleColor);
        g2d.fillOval(centerX - radius, centerY - radius, radius * 2, radius * 2);

        for (int i = 0; i < numSquares; i++) {
            double polarAngle = 2 * Math.PI * i / numSquares;

            double x = centerX + radius * Math.cos(polarAngle);
            double y = centerY + radius * Math.sin(polarAngle);

            AffineTransform oldTransform = g2d.getTransform();

            g2d.translate(x, y);
            g2d.rotate(polarAngle);

            g2d.setColor(squareColor);
            g2d.fillRect(0, -side / 2, side, side);

            g2d.setTransform(oldTransform);
        }
    }
}
```
]

== Главный класс PictureForm

Главный класс создаёт интерфейс пользователя с элементами управления:

#terminal(title: "PictureForm.java")[
```java
public class PictureForm {
    private JSpinner radiusSpinner;
    private JSpinner sideSpinner;
    private CanvasPanel canvasPanel;

    public PictureForm() {
        radiusSpinner.addChangeListener(new ChangeListener() {
            @Override
            public void stateChanged(ChangeEvent changeEvent) {
                int radius = (int) radiusSpinner.getValue();
                canvasPanel.setRadius(radius);
                canvasPanel.repaint();
            }
        });

        sideSpinner.addChangeListener(new ChangeListener() {
            @Override
            public void stateChanged(ChangeEvent changeEvent) {
                int side = (int) sideSpinner.getValue();
                canvasPanel.setSide(side);
                canvasPanel.repaint();
            }
        });

        radiusSpinner.setValue(150);
        sideSpinner.setValue(30);
    }

    public void createUIComponents() {
        JColorChooser squareColorChooser = new JColorChooser(squareColor);
        squareColorJPanel.add(squareColorChooser);
        squareColorChooser.getSelectionModel().addChangeListener(...);
    }

    public static void main(String[] args) {
        JFrame frame = new JFrame("PictureForm");
        frame.setContentPane(new PictureForm().mainPanel);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.pack();
        frame.setVisible(true);
    }
}
```
]

Элементы управления:
- `radiusSpinner` — регулировка радиуса окружности
- `sideSpinner` — регулировка размера квадратов
- `JColorChooser` — выбор цвета окружности и квадратов


= Приложение RubiksCubeApp

Приложение RubiksCubeApp реализует 3D-визуализацию кубика Рубика с использованием библиотеки FlatLaF для современного внешнего вида.

== Класс Sticker

Класс `Sticker` представляет одну грань кубика и содержит:
- цвет грани
- координаты центра
- нормаль грани
- вершины четырёхугольника

#terminal(title: "Sticker.java")[
```java
public class Sticker {
  public Color color;
  public double[] center;
  public double[] normal;
  public double[][] vertices;

  public void rotateX(double angleDegrees) {
    double rad = Math.toRadians(angleDegrees);
    double cos = Math.cos(rad);
    double sin = Math.sin(rad);
    rotatePointX(this.center, cos, sin);
    rotatePointX(this.normal, cos, sin);
    for (double[] v : vertices)
      rotatePointX(v, cos, sin);
  }

  public void rotateY(double angleDegrees) {
    double rad = Math.toRadians(angleDegrees);
    double cos = Math.cos(rad);
    double sin = Math.sin(rad);
    rotatePointY(this.center, cos, sin);
    rotatePointY(this.normal, cos, sin);
    for (double[] v : vertices)
      rotatePointY(v, cos, sin);
  }

  public void rotateZ(double angleDegrees) {
    double rad = Math.toRadians(angleDegrees);
    double cos = Math.cos(rad);
    double sin = Math.sin(rad);
    rotatePointZ(this.center, cos, sin);
    rotatePointZ(this.normal, cos, sin);
    for (double[] v : vertices)
      rotatePointZ(v, cos, sin);
  }

  public int[][] getScreenCoordinates(...) {
    if (this.normal[2] < 0.001)
      return null;
    // проецирование 3D → 2D
  }
}
```
]

Методы вращения используют матрицы поворота:
- `rotateX()` — вращение вокруг оси X
- `rotateY()` — вращение вокруг оси Y
- `rotateZ()` — вращение вокруг оси Z

Метод `getScreenCoordinates()` выполняет перспективное проецирование 3D-координат на 2D-экран.

== Класс CubeCanvas

Класс `CubeCanvas` управляет генерацией и отрисовкой кубика:

#terminal(title: "RubiksCubeApp.java")[
```java
private static class CubeCanvas extends JPanel {
    private int cubeSize = 3;
    private List<Sticker> baseCubeStickers;

    private static final Color[] COLORS = {
        new Color(0, 81, 186),   // синий
        new Color(0, 158, 96),    // зелёный
        new Color(255, 255, 255),  // белый
        new Color(255, 213, 0),   // жёлтый
        new Color(196, 30, 58),  // красный
        new Color(255, 88, 0)   // оранжевый
    };

    private void generateCube(int size) {
        baseCubeStickers = new ArrayList<>();
        double offset = size / 2.0;
        double r = 0.46;

        for (int face = 0; face < 6; face++) {
            for (int i = 0; i < size; i++) {
                for (int j = 0; j < size; j++) {
                    // генерация граней кубика
                }
            }
        }
    }

    @Override
    protected void paintComponent(Graphics g) {
        // сортировка по глубине и отрисовка
        frameStickers.sort(Comparator.comparingDouble(s -> s.center[2]));

        for (Sticker s : frameStickers) {
            int[][] coords = s.getScreenCoordinates(...);
            if (coords != null) {
                g2d.setColor(s.color);
                g2d.fillPolygon(xPoints, yPoints, 4);
            }
        }
    }
}
```
]

== Главное окно приложения

#terminal(title: "RubiksCubeApp.java")[
```java
public class RubiksCubeApp extends JFrame {
    private JSpinner sizeSpinner;
    private JSpinner angleXSpinner;
    private JSpinner angleYSpinner;
    private JSpinner angleZSpinner;
    private JSpinner cameraDistanceSpinner;
    private JSpinner scaleSpinner;

    public RubiksCubeApp() {
        setTitle("Кубик Рубика");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(800, 600);

        canvas = new CubeCanvas();
        JPanel controlPanel = createControlPanel();
        add(controlPanel, BorderLayout.NORTH);
        add(canvas, BorderLayout.CENTER);
    }

    private JPanel createControlPanel() {
        // создание панелей управления
        sizeSpinner = new JSpinner(new SpinnerNumberModel(3, 1, 100, 1));
        angleXSpinner = new JSpinner(new SpinnerNumberModel(120, 0, 3600, 1));
        angleYSpinner = new JSpinner(new SpinnerNumberModel(145, 0, 3600, 1));
        angleZSpinner = new JSpinner(new SpinnerNumberModel(90, 0, 3600, 1));

        JButton shuffleButton = new JButton("Перемешать цвета");
        shuffleButton.addActionListener(e -> {
            canvas.shuffleColors();
            canvas.repaint();
        });
    }

    public static void main(String[] args) {
        try {
            UIManager.setLookAndFeel(new FlatDarkLaf());
        } catch (Exception e) {
            e.printStackTrace();
        }
        SwingUtilities.invokeLater(() -> {
            RubiksCubeApp app = new RubiksCubeApp();
            app.setVisible(true);
        });
    }
}
```
]

Элементы управления:
- `sizeSpinner` — размер кубика (1-100)
- `angleXSpinner`, `angleYSpinner`, `angleZSpinner` — углы поворота
- `cameraDistanceSpinner` — расстояние до камеры
- `scaleSpinner` — масштаб отображения
- `shuffleButton` — перемешивание цветов


= Сборка и запуск

== PictureForm

Компиляция и запуск:

#terminal(title: "terminal")[
```bash
$ javac PictureForm.java
$ java PictureForm
```
]

== RubiksCubeApp

Для сборки используется Makefile:

#terminal(title: "Makefile")[
```makefile
.PHONY: all clean run

all:
	javac -cp lib/flatlaf-3.7.jar src/*.java

run:
	java -cp .:lib/flatlaf-3.7.jar RubiksCubeApp

clean:
	rm -f src/*.class
```
]

#terminal(title: "terminal")[
```bash
$ cd dop
$ make
$ make run
```
]

Результат — окно с 3D-кубиком Рубика, который можно вращать вокруг осей X, Y, Z с помощью регуляторов.


= Вывод

В ходе лабораторной работы были разработаны два графических приложения на Java Swing:

1. **PictureForm** — приложение для рисования окружности с квадратами, расположенными по периметру. Реализованы элементы управления для изменения радиуса, размера квадратов и выбора цветов.

2. **RubiksCubeApp** — приложение для 3D-визуализации кубика Рубика. Реализованы:
   - генерация кубика заданного размера
   - вращение вокруг осей X, Y, Z
   - перспективное проецирование
   - сортировка граней по глубине (z-buffer)
   - перемешивание цветов

Оба приложения демонстрируют основные принципы работы со Swing: использование JFrame, JPanel, JSpinner, JColorChooser, JButton и обработка событий.