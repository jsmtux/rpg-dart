library game_state;

import 'dart:html';

import 'package:game_loop/game_loop_html.dart';

import 'drawable.dart';
import 'renderer.dart';
import 'element.dart';
import 'behaviour.dart';
import 'path.dart';

class GameState extends SimpleHtmlState
{
  Renderer renderer_;
  List<EngineElement> elements_ = new List<EngineElement>();
  Map<String, Path> paths_ = new Map<String, Path>();

  EngineElement addElement(Drawable drawable, Behaviour behaviour)
  {
    EngineElement toAdd = new EngineElement(drawable, behaviour);
    if (behaviour != null)
    {
      behaviour.init(toAdd);
    }

    elements_.add(toAdd);
    int num_elements = elements_.length;
    renderer_.addDrawable(toAdd.drawable_);
    return toAdd;
  }

  void onRender(GameLoop gameLoop) {
    renderer_.render();
  }

  void onUpdate(GameLoop gameLoop)
  {
    for (EngineElement element in elements_)
    {
      if(element.behaviour_ != null)
      {
        element.behaviour_.update(this);
      }
    }
  }

  void onKeyDown(KeyboardEvent event) {
  }

  GameState(Renderer renderer)
  {
    renderer_ = renderer;
  }
}