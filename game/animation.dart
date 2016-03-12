library animation;

class AnimationSequence
{
  List<int> images;
  double time;
  AnimationSequence(this.images, this.time);
}

class AnimationData
{
  int num_images_side_;
  Map<String, AnimationSequence> sequences_;
}