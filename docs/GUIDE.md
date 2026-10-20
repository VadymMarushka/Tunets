# Tunets — гайд по коду

Короткий путівник по проєкту: де лежить кожен екран і компонент, як одна кодова база
малює два різні інтерфейси (Android і Windows), і як додати щось нове.

---

## 1. Головна ідея: один код, два дизайни

| Платформа | Дизайн-система | Бібліотека | Навігація |
|---|---|---|---|
| Android (телефон) | Material 3 | `flutter/material.dart` | нижня панель `NavigationBar` |
| Android (планшет ≥ 840 dp) | Material 3 | `flutter/material.dart` | бічна `NavigationRail` |
| Windows | Fluent Design | пакет `fluent_ui` | бічна панель `NavigationView` |

Який дизайн показувати, вирішує **одна перевірка** —
[`PlatformStyle.isFluent`](../lib/core/platform/platform_style.dart):

```dart
static bool get isFluent => defaultTargetPlatform == TargetPlatform.windows;
```

* `true` → Windows → Fluent-віджети (`fl.TextBox`, `fl.Button`, `fl.ContentDialog`…)
* `false` → Android → Material-віджети (`TextField`, `FilledButton`, `AlertDialog`…)

Екрани **не** перевіряють платформу на кожному кроці. Вони збираються зі
**спільних віджетів** (`core/widgets`), а вже кожен спільний віджет сам малює
потрібну версію. Тому код екранів майже однаковий для обох платформ.

### Як знайти код конкретної платформи

У кожному файлі, де є обидві версії, зверху стоїть позначка
`PLATFORM-SPECIFIC CODE`, а всередині:

```dart
// ===== Android (Material 3) =====      ← метод _buildMaterial(...)
// ===== Windows (Fluent) =====          ← метод _buildFluent(...)
// ----- Windows (Fluent); the Android (Material 3) version follows -----
if (... // Windows (Fluent) only
if (... // Android (Material 3) only
```

У виразах `isFluent ? a : b` — **`a` завжди Windows, `b` завжди Android**.

Шукати по проєкту зручно через `Ctrl+Shift+F` у VS Code: `Windows (Fluent)` або
`Android (Material 3)`.

> Fluent-бібліотека імпортується з префіксом: `import 'package:fluent_ui/fluent_ui.dart' as fl;`
> Тому все, що починається з `fl.` — це Windows. Без префікса — Material/Flutter.
> Префікс потрібен, бо обидві бібліотеки мають класи з однаковими назвами
> (`Card`, `IconButton`, `FilledButton`, `showDialog`…).

---

## 2. Структура папок

```
lib/
├── main.dart                 точка входу — просто запускає TunetsApp
├── app/                      «каркас» застосунку
│   ├── tunets_app.dart       MaterialApp або FluentApp + теми
│   ├── app_shell.dart        навігація після входу (нижня/бічна панель)
│   └── app_routes.dart       переходи між екранами (push / pop)
├── core/                     усе спільне, не прив'язане до конкретного екрана
│   ├── platform/             PlatformStyle (яка платформа) + Breakpoints (ширини)
│   ├── strings/              усі тексти інтерфейсу (англійською)
│   ├── theme/                кольори, відступи, шрифти, іконки, теми
│   ├── utils/                форматування дат і ваги
│   └── widgets/              спільні віджети (вимога методички, п. 5)
├── data/                     дані
│   ├── models/               Trip, Weather, CatchEntry, UserProfile
│   └── mock/                 захардкоджені дані (замість Firebase)
└── features/                 екрани, згруповані за функціями
    ├── auth/                 S-1, S-2, S-3
    ├── home/                 S-4
    ├── trips/                S-5, S-6, S-7
    └── profile/              S-8
```

---

## 3. Екрани (S-n з ЛР02)

| ID | Екран | Файл | Вимога |
|---|---|---|---|
| S-1 | Вхід | [features/auth/sign_in_screen.dart](../lib/features/auth/sign_in_screen.dart) | FR-1 |
| S-2 | Реєстрація | [features/auth/register_screen.dart](../lib/features/auth/register_screen.dart) | FR-1 |
| S-3 | Відновлення пароля | [features/auth/reset_password_screen.dart](../lib/features/auth/reset_password_screen.dart) | FR-1 |
| S-4 | Головний екран | [features/home/home_screen.dart](../lib/features/home/home_screen.dart) | FR-3 |
| S-5 | Список виїздів | [features/trips/trips_screen.dart](../lib/features/trips/trips_screen.dart) | FR-4 |
| S-6 | Форма виїзду | [features/trips/trip_form_screen.dart](../lib/features/trips/trip_form_screen.dart) | FR-4, FR-5 |
| S-7 | Деталі виїзду | [features/trips/trip_details_screen.dart](../lib/features/trips/trip_details_screen.dart) | FR-4, FR-5 |
| S-8 | Профіль | [features/profile/profile_screen.dart](../lib/features/profile/profile_screen.dart) | FR-2, FR-5 |

Що де всередині:

* **sign_in_screen** — кнопка «Sign in» викликає `context.resetTo(const AppShell())`,
  тобто просто відкриває головний екран (без перевірки пароля — так дозволяє методичка).
* **home_screen** — привітання, бейдж `Synced`, останні 3 виїзди. На широкому вікні
  справа картка `_SummaryCard` (статистика за місяць).
* **trips_screen** — пошук + фільтри. На вузькому екрані — просто список
  (тап відкриває деталі окремою сторінкою). На широкому — **master–detail**:
  список зліва, деталі вибраного виїзду справа (`_DetailsPane`).
* **trip_details_screen** — два класи: `TripDetailsScreen` (окрема сторінка) і
  `TripDetailsView` (сам вміст; його ж показує права панель у master–detail).
  Тут же `confirmDeleteTrip` — діалог видалення.
* **trip_form_screen** — створення/редагування. Стан форми (дата, водойма, список
  снастей, список уловів `_CatchDraft`) живе в `_TripFormScreenState`.
  Кнопки: на Android — знизу (`_MaterialFormBar`), на Windows — у заголовку.
* **profile_screen** — дві секції: `_PersonalInfoSection` і `_ChangePasswordSection`.
  На широкому вікні стоять у дві колонки.

---

## 4. Спільні віджети (`lib/core/widgets`)

| Віджет | Файл | Android | Windows | Де використовується |
|---|---|---|---|---|
| `AppPage`, `PageAction` | [app_page.dart](../lib/core/widgets/app_page.dart) | `Scaffold` + `AppBar` + FAB | `ScaffoldPage` + `PageHeader` з кнопками | усі екрани після входу |
| `ContentConstraint`, `pagePadding()` | [app_page.dart](../lib/core/widgets/app_page.dart) | — | — | обмеження ширини і відступи сторінки |
| `AuthLayout`, `AuthSwitchLine` | [auth_layout.dart](../lib/core/widgets/auth_layout.dart) | форма на весь екран | картка по центру на «mica»-фоні | S-1, S-2, S-3 |
| `AppTextField`, `FieldLabel` | [app_text_field.dart](../lib/core/widgets/app_text_field.dart) | `TextField` | `fl.TextBox` | усі форми |
| `PasswordField` | [password_field.dart](../lib/core/widgets/password_field.dart) | `TextField` + кнопка «око» | `fl.PasswordBox` | вхід, реєстрація, профіль |
| `AppButton` (`primary/secondary/text/danger`), `AppIconButton` | [app_button.dart](../lib/core/widgets/app_button.dart) | `FilledButton` / `OutlinedButton` / `TextButton` | `fl.FilledButton` / `fl.Button` / `fl.HyperlinkButton` | всюди |
| `AppCard` | [app_card.dart](../lib/core/widgets/app_card.dart) | Material `Card` з ripple | шар з рамкою, hover і фокус | картки, секції |
| `AppSelectField` | [app_pickers.dart](../lib/core/widgets/app_pickers.dart) | `DropdownButtonFormField` | `fl.ComboBox` | водойма, вид риби, вітер |
| `AppDateField`, `AppTimeField` | [app_pickers.dart](../lib/core/widgets/app_pickers.dart) | системні `showDatePicker` / `showTimePicker` | `fl.DatePicker` / `fl.TimePicker` | форма виїзду |
| `FilterBar`, `AppSearchField` | [filter_bar.dart](../lib/core/widgets/filter_bar.dart) | `FilterChip`, `SearchBar` | `fl.ToggleButton`, `fl.TextBox` | список виїздів |
| `showConfirmDialog`, `showNotice`, `showPhotoSourcePicker` | [dialogs.dart](../lib/core/widgets/dialogs.dart) | `AlertDialog`, `SnackBar`, bottom sheet | `fl.ContentDialog`, `fl.InfoBar` | видалення, «збережено», фото |
| `FluentNoticeStack` | [notice_stack.dart](../lib/core/widgets/notice_stack.dart) | — (на Android один `SnackBar`) | стовпчик до 3 `fl.InfoBar` знизу справа | викликається з `showNotice` |
| `PhotoDropZone` | [photo_drop_zone.dart](../lib/core/widgets/photo_drop_zone.dart) | плитка «Add photo» | зона «Drag a photo here» | улов у формі |
| `TripCard` | [trip_card.dart](../lib/core/widgets/trip_card.dart) | спільний | спільний | головний, список |
| `InfoChip`, `WeatherChips`, `SyncBadge` | [info_chips.dart](../lib/core/widgets/info_chips.dart) | спільні | спільні | картки, деталі |
| `StatRow`, `StatCard` | [stat_tile.dart](../lib/core/widgets/stat_tile.dart) | спільні | спільні | Summary, погода |
| `SectionHeader`, `EmptyState`, `AppDivider` | [section_header.dart](../lib/core/widgets/section_header.dart) | спільні | спільні | заголовки, порожні списки |
| `AppLogo`, `FishMark`, `FishIcon`, `UserAvatar`, `FishThumbnail`, `TripPhoto` | [brand.dart](../lib/core/widgets/brand.dart) | спільні | спільні | лого (рибка на гачку), іконка рибки для уловів, аватар, мініатюри |

«Спільні» віджети не мають окремих версій — вони зібрані з базових Flutter-віджетів
(`Container`, `Row`, `Text`…) і однаково виглядають на обох платформах.

---

## 5. Навігація

**До входу:** `TunetsApp` → `SignInScreen`. Звідти `pushPage(...)` на реєстрацію
чи відновлення пароля, `Navigator.pop` — назад.

**Після входу:** `resetTo(const AppShell())` очищає весь стек (щоб кнопка «назад»
не повертала на екран входу) і показує [`AppShell`](../lib/app/app_shell.dart).

`AppShell` має три розділи (`AppTab.home / trips / profile`). У **кожного розділу
свій вкладений `Navigator`**, тому коли відкриваєш деталі виїзду, нижня/бічна
панель лишається на екрані.

Хелпери з [app_routes.dart](../lib/app/app_routes.dart):

| Метод | Що робить |
|---|---|
| `context.pushPage(screen)` | відкрити сторінку всередині поточного розділу |
| `context.pushFullScreen(screen)` | на Android — поверх усього (без нижньої панелі; так відкривається форма), на Windows — як `pushPage` |
| `context.resetTo(screen)` | замінити весь стек (вхід / вихід) |
| `appRoute(builder)` | `MaterialPageRoute` на Android, `FluentPageRoute` на Windows |

Перемкнути розділ з екрана (наприклад, «See all» на Home → Trips):
`AppShellScope.maybeOf(context)?.selectTab(AppTab.trips)`.

**Windows-панель:** режим `compact` — завжди видно щонайменше колонку іконок.
Кнопка-логотип (`_LogoPaneToggle` в `app_shell.dart`) розгортає/згортає підписи.
На широкому вікні (≥ 840 px) панель стартує розгорнутою.
Користувач унизу панелі — `_UserPaneFooter` (власний елемент замість `PaneItem`,
бо Fluent обмежує іконки згорнутої панелі до 14 px). Висота заголовка панелі
однакова в обох режимах (`_paneHeaderHeight`), тому пункти не «стрибають».
Сповіщення (`showNotice`) на Windows з'являються знизу справа стовпчиком до 3 штук
([notice_stack.dart](../lib/core/widgets/notice_stack.dart)): нове — знизу, найстаріше зникає,
кожне закривається саме через 4 с.

---

## 6. Тема, кольори, тексти

| Що | Файл | Примітка |
|---|---|---|
| Кольори (світла + темна) | [theme/app_colors.dart](../lib/core/theme/app_colors.dart) | `AppPalette.of(context)` — бере палітру за системною темою. Значення 1:1 з макета |
| Material-тема | [theme/material_theme.dart](../lib/core/theme/material_theme.dart) | кнопки, поля, навігація для Android |
| Fluent-тема | [theme/fluent_theme.dart](../lib/core/theme/fluent_theme.dart) | акцентний колір і колір панелі для Windows |
| Відступи, радіуси, розміри | [theme/app_spacing.dart](../lib/core/theme/app_spacing.dart) | крок 8 (4, 8, 12, 16, 24…) |
| Стилі тексту | [theme/app_text_styles.dart](../lib/core/theme/app_text_styles.dart) | `headline`, `title`, `subtitle`, `body`, `caption`… |
| Іконки | [theme/app_icons.dart](../lib/core/theme/app_icons.dart) | Material Symbols на Android, Fluent-іконки на Windows |
| Ширини екранів | [platform/platform_style.dart](../lib/core/platform/platform_style.dart) | `Breakpoints.compact = 600`, `expanded = 840` |
| Тексти | [strings/app_strings.dart](../lib/core/strings/app_strings.dart) | **усі** рядки UI тут, англійською |

Правило: у віджетах **не пишемо** кольори (`Color(0xFF...)`) і тексти напряму —
тільки `AppPalette.of(context).primary`, `AppStrings.signIn` тощо.

---

## 7. Дані

* [data/models](../lib/data/models) — прості класи: `Trip` (виїзд), `Weather`,
  `CatchEntry` (один вид улову), `UserProfile`.
* [data/mock/mock_data.dart](../lib/data/mock/mock_data.dart) — захардкоджені
  користувач і 4 виїзди. `MockData.today` = 29.09.2026, щоб фільтр «This month» і
  Summary показували вересень, як у макеті.

У наступних лабах `MockData` заміниться репозиторієм, який читає з Firebase;
екрани для цього майже не доведеться змінювати.

---

## 8. Рецепти

**Додати новий екран:**
1. Створити файл у `features/<розділ>/`, клас `XxxScreen extends StatelessWidget`.
2. Обгорнути вміст в `AppPage(title: ..., body: ...)` — отримаєш правильний
   заголовок на обох платформах.
3. Будувати з віджетів `core/widgets` (`AppTextField`, `AppButton`, `AppCard`…).
4. Тексти — в `AppStrings`.
5. Відкрити: `context.pushPage(const XxxScreen())`.

**Додати новий спільний віджет з різним виглядом:**
1. Файл у `core/widgets/`.
2. У `build`: `return PlatformStyle.isFluent ? _buildFluent(context) : _buildMaterial(context);`
3. Два методи з позначками `// ===== Android (Material 3) =====` та
   `// ===== Windows (Fluent) =====`.

**Подивитися Windows-вигляд у тесті:** див. [test/widget_test.dart](../test/widget_test.dart) —
там `debugDefaultTargetPlatformOverride = TargetPlatform.windows`.

---

## 9. Запуск

```bash
flutter run -d windows          # Windows
flutter devices                 # список пристроїв (телефон має бути тут)
flutter run -d <id телефона>    # на телефон з hot reload
flutter build apk --release     # APK для встановлення
flutter install -d <id> --release
flutter analyze                 # перевірка коду
flutter test                    # тести
```
