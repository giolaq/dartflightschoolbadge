// 2014, Giovanni Laquidara.  

import 'dart:html';
import 'dart:math' show Random;
import 'dart:convert' show JSON;
import 'dart:async' show Future;
import 'dart:svg';

final String MILITARY_KEY = 'militaryUnit';

ButtonElement genButton;

TSpanElement  nameElement, rankElement;

void  main() {
  InputElement inputField = querySelector('#inputName');
  inputField.onInput.listen(updateBadge);
  genButton = querySelector('#generateButton');
  genButton.onClick.listen(generateBadge);
  
  nameElement = querySelector('#tspan3547');

  rankElement = querySelector('#tspan3641');
  
  MilitaryUnit.readyTheMilitaries()
    .then((_) {
      //on success
      inputField.disabled = false; //enable
      genButton.disabled = false;  //enable
      setBadgeName(getBadgeNameFromStorage());
    })
    .catchError((arrr) {
      print('Error initializing pirate names: $arrr');
      nameElement.text = "Aiaaa";

      rankElement.text = "Aiaaa";
    });
  
 
}

void updateBadge(Event e) {
  String inputName = (e.target as InputElement).value;
  
  setBadgeName(new MilitaryUnit(firstName: inputName));
  if (inputName.trim().isEmpty) {
    genButton..disabled = false
             ..text = 'Tell me your name!';
  } else {
    genButton..disabled = true
             ..text = 'Write your name!';
  }
}

void generateBadge(Event e) {
  setBadgeName(new MilitaryUnit());
}

void setBadgeName(MilitaryUnit newName) {
  if (newName == null) {
    return;
  }
  nameElement.text = newName.militaryName;
  rankElement.text = newName.militaryRank;
  window.localStorage[MILITARY_KEY] = newName.jsonString;
  Element container = querySelector('#container');
  String contents = container.innerHtml;

  Blob blob = new Blob([contents]);
  AnchorElement downloadLink = new AnchorElement(href: Url.createObjectUrlFromBlob(blob));
  downloadLink.text = 'Download Badge';
  downloadLink.download = 'flightschoolBadge.svg';


  AnchorElement download = querySelector('a');
  download.replaceWith(downloadLink);

}

MilitaryUnit getBadgeNameFromStorage() {
  String storedName = window.localStorage[MILITARY_KEY];
  if (storedName != null) {
    return new MilitaryUnit.fromJSON(storedName);
  } else {
    return null;
  }
}

class MilitaryUnit {
  
  static final Random indexGen = new Random();

  static List<String> names = [];
  static List<String> ranks = [];

  String _firstName;
  String _rank;
  
  MilitaryUnit({String firstName, String rank}) {
    
    if (firstName == null) {
      _firstName = names[indexGen.nextInt(names.length)];
    } else {
      _firstName = firstName;
    }
    if (rank == null) {
      _rank = ranks[indexGen.nextInt(ranks.length)];
    } else {
      _rank = rank;
    }
  }

  MilitaryUnit.fromJSON(String jsonString) {
    Map storedName = JSON.decode(jsonString);
    _firstName = storedName['f'];
    _rank = storedName['a'];
  }

  String toString() => militaryName;

  String get jsonString => '{ "f": "$_firstName", "a": "$_rank" } ';

  String get militaryName => _firstName.isEmpty ? '' : '$_firstName';

  String get militaryRank => _firstName.isEmpty ? '' : '$_rank';

  static Future readyTheMilitaries() {
    String path = 'ranks.json';
    return HttpRequest.getString(path)
        .then(_parseMilitaryUnitFromJSON);
  }
  
  static _parseMilitaryUnitFromJSON(String jsonString) {
    Map militaryUnit = JSON.decode(jsonString);
    names = militaryUnit['names'];
    ranks = militaryUnit['ranks'];
  }
}