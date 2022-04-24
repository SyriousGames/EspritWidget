part of flint_particles;

/// Randomly selects from one of the supplied [spriteTextureName]s, using
/// optional weighting values to produce an uneven distribution for the choice,
/// and applies it to the particle.
class TexturesInit extends InitializerBase {
  late WeightedList<String> spriteTextureNames;

  TexturesInit({WeightedList<String>? spriteTextureNames}) {
    this.spriteTextureNames = spriteTextureNames ?? WeightedList();
  }

  void add(String spriteTextureName, [double weight = 1]) {
    spriteTextureNames.add(spriteTextureName, weight);
  }

  @override
  void initialize(Emitter emitter, Particle particle) {
    particle.spriteTextureName = spriteTextureNames.getRandomValue();
  }
}
