embedded_components {
  id: "label"
  type: "label"
  data: "size {\n"
  "  x: 128.0\n"
  "  y: 32.0\n"
  "}\n"
  "color {\n"
  "  x: 0.302\n"
  "  y: 0.302\n"
  "  z: 0.302\n"
  "}\n"
  "text: \"X\"\n"
  "font: \"/resources/game.font\"\n"
  "material: \"/builtins/fonts/label-df.material\"\n"
  ""
  position {
    y: 4.0
    z: 0.1
  }
  scale {
    x: 1.4
    y: 1.4
  }
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"cell_bg\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "size {\n"
  "  x: 72.0\n"
  "  y: 72.0\n"
  "}\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/resources/game.atlas\"\n"
  "}\n"
  ""
}
