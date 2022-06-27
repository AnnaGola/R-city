# R-city
## Приложение по сохранению любимых мест в городе
----
В проекте я использовала:
* MVC архитектуру
* Realm для сохранения данных на устройстве
* GCD для работы с асинхронным потоком через DispatchQueue.asyncAfter
* MapKit и CoreLocation, выводя разный вид и интерфейс карт в зависимости от того, с какой кнопки совершается переход
* Вёрстка кодом и в storyboard
* В проекте я не использую свойства, которые могут принимать замыкания и вести за собой утечку памяти, работала только с методами.

## Главный экран 

Изначально главный экран инициализируется для пользователя только Заголовком экрана, в данном случае рассматривается на примере города Суздаль, также отображается занчек добавления нового места в виде "+". 

<img src="https://github.com/AnnaGola/R-city/blob/realmBranch/Screenshots/IMG_7282.PNG" width="160">


## Создание нового места пользователем

При нажатии на "+" в правом верхнем углу экрана, пользователь перейдет на другой экран под названием "New Place" в котором может выбрать изображение из фотоальбома или сделать снимок на месте.

 <img src="https://github.com/AnnaGola/R-city/blob/realmBranch/Screenshots/IMG_7287.PNG" width="160">.   <img src="https://github.com/AnnaGola/R-city/blob/realmBranch/Screenshots/IMG_7288.PNG" width="160">

Если же пользователь не прикрепит фото к месту, оно прикрепится по дефолту из каталога assets.

<img src="https://github.com/AnnaGola/R-city/blob/realmBranch/Screenshots/blabk-map-pin-flat-location-sign-blank-circle-icon-vector-10812853.jpg" width="160">

Далее обязательно нужно установить название места и его адрес, без котороих кнопка  **SAVE**  не будет работать, и опционально краткое описание.

```swift
@objc private func textFieldChanged() {
        if placeLocationTF.text?.isEmpty == false && placeNameTF.text?.isEmpty == false {
           saveButton.isEnabled = true
        } else {
           saveButton.isEnabled = false
        }
    }
```
## Экран редактирования
По нажатию на сохраненное место происходит переход на экран редактирования, в котором можно поменять изображение (если его не выбирать, изображение будет выгружено по дефолту из каталога assets), поменять название места, описание и адрес, написав его вручную или выбрать значек в правом углу строки, при нажатии на который вы перейдете на карту и сможете перемещением иконки с меткой определить адрес.

<img src="https://github.com/AnnaGola/R-city/blob/realmBranch/Screenshots/IMG_7283.PNG" width="160">.  <img src="https://github.com/AnnaGola/R-city/blob/realmBranch/Screenshots/IMG_7284.PNG" width="160">

## Карты
### Карта одна, но при переходе с разных кнопок открывается она по разному

***Карта из поля редактирования Image*** открывается карта с таким функционалом:

* Кнопка закрытия экрана в правом верхнем углу [x] благодаря функуии dismiss()
* Кнопка для отображения геологации пользователя на данный момент.
* Кнопка для нахождения всех пеших маршрутов до пункта назначения от местоположения пользователя, показывающая через расширение расстояние в километрах и время в минутах до этого места.

     <img src="https://github.com/AnnaGola/R-city/blob/realmBranch/Screenshots/IMG_7285.PNG" width="160">
     <img src="https://github.com/AnnaGola/R-city/blob/realmBranch/Screenshots/IMG_7286.PNG" width="160">

***Карта из поля редактирования Location*** открывается карта с таким функционалом: 

//помимо кнопки закрытия экрана и кнопки определения геолокации пользователя, появляются отличные от другого экрана функции

* Красный пин, указывающий на центр экрана, при наведении его на любое место на карте, в лейбле над ним будет вывден адрес с номером улицы и дома или только с номером улици, если дом невозможно определить блягодаря GCD:

```swift
 DispatchQueue.main.async {
   if streetName != nil && buildNumber != nil {
      self.currentAddress.text = "\(streetName!), \(buildNumber!)"
   } else if streetName != nil {
      self.currentAddress.text = "\(streetName!)"
   } else {
      self.currentAddress.text = ""
    }
 }
```

<img src="https://github.com/AnnaGola/R-city/blob/realmBranch/Screenshots/IMG_7289.PNG" width="160">

* Для сохранения адреса, выставленного таким образом, есть специальная кнопка  **DONE**  внизу экрана, которая будет транслировать выбранный адрес в TextField Location на экране редактирования.

// На данный момент дорабатываю приложение, чтобы отображать все любимые места на карте одновременно, заходя с главного экрана. Также есть некоторые функции, которые уже прописаны, но вместо полной реализации там добавлены только алерты с предупреждением, что этот раздел находится в разработке: 

```swift
 @objc func handleSwipe(gesture: UISwipeGestureRecognizer) {
    let alert = UIAlertController(title: "Oops!", message: "this function is not available now, sorry", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "Okay", style: .default)
    alert.addAction(okAction)
    present(alert, animated: true)
}
```
