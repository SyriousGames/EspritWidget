part of flint_particles;

/// Initializes the particle to the supplied [spriteTextureName].
class TextureInit extends InitializerBase {
  String spriteTextureName;

  TextureInit(this.spriteTextureName);

  @override
  void initialize(Emitter emitter, Particle particle) {
    particle.spriteTextureName = spriteTextureName;
  }
}
