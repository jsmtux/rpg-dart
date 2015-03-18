library game_state;

import 'dart:html';

import 'package:game_loop/game_loop_html.dart';

import 'drawable.dart';
import 'renderer.dart';
import 'behaviour.dart';
import 'path.dart';

class GameState extends SimpleHtmlState
{
  Renderer renderer_;
  List<Drawable> drawables_ = new List<Drawable>();
  List<Behaviour> behaviours_ = new List<Behaviour>();
  Map<String, Path> paths_ = new Map<String, Path>();

  void addElement(Drawable drawable, Behaviour behaviour)
  {
    if (behaviour != null)
    {
      behaviour.init(drawable);
    }

    drawables_.add(drawable);
    behaviours_.add(behaviour);
    int num_elements = drawables_.length;
  }

  void onRender(GameLoop gameLoop) {
    renderer_.render(drawables_);
  }

  void onUpdate(GameLoop gameLoop)
  {
    for (Behaviour behaviour in behaviours_)
    {
      behaviour.update(this);
    }
  }

  void onKeyDown(KeyboardEvent event) {
  }

  GameState(Renderer renderer)
  {
    renderer_ = renderer;
  }
}