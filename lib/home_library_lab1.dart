const _fieldDelimiter = ';';
const _bookFieldCount = 6;

/// Книга домашньої бібліотеки без використання класу.
typedef Book = ({
  String author,
  String title,
  int publicationYear,
  int pageCount,
  String genre,
  DateTime readDate,
});

/// Результат розбору одного вхідного рядка.
typedef BookParseResult = ({Book? book, String? error});

/// Результат розбору всього набору вхідних рядків.
typedef BookListParseResult = ({List<Book> books, List<String> errors});

/// Вхідні дані у CSV-подібному форматі з роздільником `;`.
///
/// Чотири останні рядки навмисно пошкоджено: у них відсутнє поле,
/// нечисловий рік, нечислова кількість сторінок і некоректна дата.
const bookInputLines = <String>[
  'Джордж Орвелл;1984;1949;328;антиутопія;2025-01-12',
  'Рей Бредбері;451 градус за Фаренгейтом;1953;256;антиутопія;2025-02-03',
  'Френк Герберт;Дюна;1965;656;фантастика;2025-02-21',
  'Джон Толкін;Гобіт;1937;304;фентезі;2025-03-15',
  'Агата Крісті;Вбивство у Східному експресі;1934;288;детектив;2025-04-08',
  'Артур Конан Дойл;Собака Баскервілів;1902;256;детектив;2025-04-27',
  'Еріх Марія Ремарк;Три товариші;1936;480;роман;2025-05-19',
  'Джейн Остін;Гордість і упередження;1813;416;роман;2025-06-02',
  'Оскар Вайлд;Портрет Доріана Грея;1890;320;роман;2025-06-20',
  'Маркус Зузак;Крадійка книжок;2005;576;роман;2025-07-14',
  'Деніел Кіз;Квіти для Елджернона;1966;312;фантастика;2025-08-01',
  'Стівен Кінг;Зелена миля;1996;432;містика;2025-08-24',
  'Іван Багряний;Тигролови;1944;304;пригоди;2025-09-11',
  'Валер\u0027ян Підмогильний;Місто;1928;352;роман;2025-10-05',
  'Ліна Костенко;Маруся Чурай;1979;224;історичний роман',
  'Сергій Жадан;Інтернат;дві тисячі сімнадцять;336;роман;2025-10-22',
  'Макс Кідрук;Колонія;2023;шістсот;фантастика;2025-11-02',
  'Тарас Шевченко;Кобзар;1840;384;поезія;невідома дата',
];

/// Розбирає [line] у запис [Book].
///
/// Повертає опис очікуваної помилки замість аварійного завершення програми.
BookParseResult parseBook(String line) {
  final fields = line
      .split(_fieldDelimiter)
      .map((field) => field.trim())
      .toList();

  if (fields.length != _bookFieldCount) {
    return (
      book: null,
      error: 'очікується $_bookFieldCount полів, отримано ${fields.length}',
    );
  }

  if (fields.any((field) => field.isEmpty)) {
    return (book: null, error: 'одне з обов’язкових полів порожнє');
  }

  final publicationYear = int.tryParse(fields[2]);
  if (publicationYear == null) {
    return (book: null, error: 'рік видання «${fields[2]}» не є цілим числом');
  }

  final pageCount = int.tryParse(fields[3]);
  if (pageCount == null) {
    return (
      book: null,
      error: 'кількість сторінок «${fields[3]}» не є цілим числом',
    );
  }

  final readDate = DateTime.tryParse(fields[5]);
  if (readDate == null) {
    return (book: null, error: 'дата прочитання «${fields[5]}» некоректна');
  }

  return (
    book: (
      author: fields[0],
      title: fields[1],
      publicationYear: publicationYear,
      pageCount: pageCount,
      genre: fields[4],
      readDate: readDate,
    ),
    error: null,
  );
}

/// Розбирає [lines] і окремо повертає коректні книги та описи помилок.
BookListParseResult parseBookLines(Iterable<String> lines) {
  final parsedLines = lines.indexed
      .map((entry) {
        final (index, line) = entry;
        return (lineNumber: index + 1, result: parseBook(line));
      })
      .toList(growable: false);

  final books = parsedLines
      .map((entry) => entry.result.book)
      .whereType<Book>()
      .toList(growable: false);

  final errors = parsedLines
      .map((entry) {
        final error = entry.result.error;
        return error == null ? null : 'Рядок ${entry.lineNumber}: $error.';
      })
      .whereType<String>()
      .toList(growable: false);

  return (books: books, errors: errors);
}

/// Запускає консольний застосунок «Домашня бібліотека».
void runApplication() {
  final result = parseBookLines(bookInputLines);

  print('Домашня бібліотека');
  print('Отримано рядків: ${bookInputLines.length}.');
  print('Успішно розібрано: ${result.books.length}.');
  print('Відхилено: ${result.errors.length}.');

  if (result.errors.isNotEmpty) {
    print('\nПомилки вхідних даних:');
    result.errors.forEach(print);
  }
}
