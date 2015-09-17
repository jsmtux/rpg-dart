library enemy_behaviour;

import 'package:vector_math/vector_math.dart';

import '../game_area.dart';
import '../path.dart';
import 'path_follower.dart';
import 'behaviour.dart';
import 'terrain_element_behaviour.dart';
import 'sheep_behaviour.dart';
import 'a_star_algorithm.dart';

class EnemyNormalState extends WalkingBehaviourState
{
  PathFollower path_follower_;
  Vector2 original_node_; // undefined if this is the original path

  EnemyNormalState(SpriteBehaviour element, Path path) : super(element, 0.03)
  {
    path_follower_ = new MapPathFollower(path);
  }

  void hit(SpriteBehaviour sprite)
  {
    EnemyBehaviour element = element_;
    element_.setState(element.dead_state_);
  }

  void update()
  {
    for (Behaviour behaviour in element_.area_.behaviours_)
    {
      double min_distance;
      BaseSheepBehaviour closest_sheep;
      if (behaviour is BaseSheepBehaviour && ! behaviour.isDead())
      {
        double dist = element_.squareDistance(behaviour);
        if (min_distance == null || dist < min_distance)
        {
          min_distance = dist;
          closest_sheep = behaviour;
        }
      }
      if (closest_sheep != null && min_distance < 12)
      {
        Vector2 getBackNode = original_node_;
        if (getBackNode == null)
        {
          getBackNode = path_follower_.getNextNode();
        }
        element_.setState(new EnemyFollowState(element_, closest_sheep, getBackNode));
      }
    }
    path_follower_.updateWalk(this);
  }

  void whenFinished(Function fun)
  {
    path_follower_.callback_ = fun;
  }
}

class EnemyFollowState extends WalkingBehaviourState
{
  BaseSheepBehaviour follow_;
  Vector2 origin_pos_;

  EnemyFollowState(SpriteBehaviour element, this.follow_, this.origin_pos_) : super(element, 0.05);
  void hit(SpriteBehaviour sprite){}

  void update()
  {
    Vector2 diff = (follow_.position_ - element_.position_);
    for (Behaviour behaviour in element_.area_.behaviours_)
    {
      double min_distance = diff.length;
      if (behaviour is BaseSheepBehaviour && ! behaviour.isDead())
      {
        BaseSheepBehaviour sheep_behaviour = behaviour;
        double dist = (sheep_behaviour.position_ - element_.position_).length;
        if (dist < min_distance)
        {
          min_distance = dist;
          follow_ = behaviour;
        }
      }
    }
    walkDir(diff);

    if (diff.length2 < 0.1)
    {
      follow_.hit(element_);
      initGetBackState();
    }
    if (diff.length2 > 20)
    {
      initGetBackState();
    }
  }

  void initGetBackState()
  {
    EnemyBehaviour this_element = element_;
    EnemyNormalState getBack = new EnemyNormalState(this_element,
    aStar(this_element.area_.terrain_.obstacles_, this_element.area_.terrain_.getSize(), this_element.position_, origin_pos_));
    getBack.whenFinished((){element_.setState(this_element.normal_state_);});
    getBack.original_node_ = origin_pos_;
    element_.setState(getBack);
  }
}

class EnemyDeadState extends BehaviourState
{
  EnemyDeadState(SpriteBehaviour element) : super(element);

  void begin()
  {
    element_.anim_drawable_.SetSequence("die", 1);
  }

  void hit(SpriteBehaviour sprite)
  {
  }

  void update()
  {
  }
}

class EnemyBehaviour extends SpriteBehaviour
{
  bool dead_ = false;
  EnemyDeadState dead_state_;
  EnemyNormalState normal_state_;

  EnemyBehaviour(GameArea area, Path path)
    : super(new Vector2(path.points[0].x.floorToDouble(), path.points[0].y.floorToDouble()), area)
  {
    dead_state_ = new EnemyDeadState(this);
    normal_state_ = new EnemyNormalState(this, path);
    cur_state_ = normal_state_;
  }
}