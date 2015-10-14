library game_area;

import 'package:vector_math/vector_math.dart';

import 'path.dart';
import 'drawable.dart';
import 'sprite_importer.dart';
import 'game_state.dart';
import 'behaviour/behaviour.dart';
import 'behaviour/terrain_behaviour.dart';


class GameArea
{
  List<Drawable> drawables_ = new List<Drawable>();
  List<Behaviour> behaviours_ = new List<Behaviour>();
  List<Drawable> drawables_to_add_ = new List<Drawable>();
  List<Behaviour> behaviours_to_add_ = new List<Behaviour>();
  List<Drawable> drawables_to_remove_ = new List<Drawable>();
  List<Behaviour> behaviours_to_remove_ = new List<Behaviour>();
  Map<String, Path> paths_ = new Map<String, Path>();
  TerrainBehaviour terrain_;
  bool iterating_ = false;
  Vector3 offset_;

  void updateBehaviour()
  {
    iterating_ = true;
    for (Behaviour behaviour in behaviours_)
    {
      behaviour.update();
    }
    iterating_ = false;
    drawables_.addAll(drawables_to_add_);
    drawables_to_add_.clear();
    behaviours_.addAll(behaviours_to_add_);
    behaviours_to_add_.clear();
    drawables_.removeWhere((drawable) => drawables_to_remove_.contains(drawable));
    drawables_to_remove_.clear();
    behaviours_.removeWhere((behaviour) => behaviours_to_remove_.contains(behaviour));
    behaviours_to_remove_.clear();
  }

  void removeElement(Behaviour behaviour)
  {
    if(iterating_)
    {
      drawables_to_remove_.add(behaviour.drawable_);
      behaviours_to_remove_.add(behaviour);
    }
    else
    {
      drawables_.remove(behaviour.drawable_);
      behaviours_.remove(behaviour);
    }

  }

  void addElement(Drawable drawable, Behaviour behaviour)
  {
    if (behaviour != null)
    {
      behaviour.init(drawable);
    }

    if(iterating_)
    {
      drawables_to_add_.add(drawable);
      behaviours_to_add_.add(behaviour);
    }
    else
    {
      drawables_.add(drawable);
      behaviours_.add(behaviour);
    }
  }
}