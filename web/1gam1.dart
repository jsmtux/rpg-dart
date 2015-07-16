import 'dart:html';

import 'package:game_loop/game_loop_html.dart';

import 'renderer.dart';
import 'game_state.dart';
import 'drawable_factory.dart';
import 'camera.dart';
import 'sprite_importer.dart';
import 'dialogue_box.dart';
import 'input.dart';

void startGame(String map, String sprites)
{
  CanvasElement canvas = querySelector("#game-element");
  DivElement div = querySelector("#game-area");
  DivElement div_analog = querySelector('#analog_control_base');
  GameLoopHtml gameLoop = new GameLoopHtml(canvas);
  gameLoop.pointerLock.lockOnClick = false;
  Input input;

  input = new CombinedInput(canvas, div_analog, gameLoop.keyboard, gameLoop.mouse);

  DialogueBox dialogue = new DialogueBox(querySelector("#dialogue"));

  Camera cur_cam = new Camera();

  Renderer renderer = new Renderer(div, canvas, cur_cam);

  DrawableFactory drawable_factory = new DrawableFactory(renderer);
  GameState draw_state = new GameState(renderer, drawable_factory);

  SpriteLoader loader = new SpriteLoader(drawable_factory, input, cur_cam, dialogue);

  draw_state.loadArea("first", map, sprites, loader)
    .then((bool ret)
        {
          gameLoop.state = draw_state;
          draw_state.setVisible("first", true);
          querySelector('#pause-button').style.display = 'block';
        });

  gameLoop.start();
}

AnchorElement addButton(String text, DivElement menu, String button_class)
{
  AnchorElement button = new AnchorElement();
  button.text = text;
  button.classes.add(button_class);
  button.classes.add("btn");
  menu.append(button);
  return button;
}

AnchorElement addMenuButton(String text, DivElement menu) => addButton(text, menu, "menu-button");

AnchorElement addGridButton(String text, DivElement menu) => addButton(text, menu, "grid-button");

main() {
  DivElement main_window = querySelector("#main-window");
  DivElement level_window = querySelector("#level-modal");
  DivElement options_window = querySelector("#options-modal");
  DivElement ingame_window = querySelector("#ingame-modal");

  addMenuButton("Start", main_window).onClick.listen((event) => level_window.classes.add("show"));
  AnchorElement options_button = addMenuButton("Options", main_window);

  DivElement pause_button = querySelector('#pause-button');
  pause_button.onClick.listen((event) => ingame_window.classes.add("show"));

  options_button.onClick.listen((event) => options_window.classes.add("show"));
  AnchorElement close_options = options_window.querySelector("#Close-options");
  close_options.onClick.listen((event) => options_window.classes.remove("show"));

  AnchorElement close_ingame = ingame_window.querySelector("#Close-ingame");
  close_ingame.onClick.listen((event) => ingame_window.classes.remove("show"));
  addMenuButton("Main menu", ingame_window);

  AnchorElement close = level_window.querySelector("#Close");
  close.onClick.listen((event) => level_window.classes.remove("show"));
  DivElement level_menu = level_window.querySelector("#level-menu");
  addGridButton("01", level_menu).onClick.listen(
      (event){startGame("images/sheep_map.json", "images/map_units_sheep.json"); level_window.classes.remove("show");});
  addGridButton("02", level_menu).onClick.listen(
      (event){startGame("images/sheep_2.json", "images/map_units_sheep_2.json"); level_window.classes.remove("show");});
  addGridButton("03", level_menu).onClick.listen(
      (event){startGame("images/sheep_3.json", "images/map_units_sheep_3.json"); level_window.classes.remove("show");});
}
