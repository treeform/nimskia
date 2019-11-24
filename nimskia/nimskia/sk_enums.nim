import ../wrapper/sk_types

type
  SKPixelGeometry* = enum
    UnknownPixelGeom = UNKNOWN_SK_PIXELGEOMETRY, 
    Rgb_H = RGB_H_SK_PIXELGEOMETRY, 
    Bgr_H = BGR_H_SK_PIXELGEOMETRY,
    Rgb_V = RGB_V_SK_PIXELGEOMETRY, 
    Bgr_V = BGR_V_SK_PIXELGEOMETRY

  SKColorType* = enum
    UnknownColorType = UNKNOWN_SK_COLORTYPE, 
    Alpha8 = ALPHA_8_SK_COLORTYPE, 
    Rgb565 = RGB_565_SK_COLORTYPE,
    Argb4444 = ARGB_4444_SK_COLORTYPE, 
    Rgba8888 = RGBA_8888_SK_COLORTYPE, 
    Rgb888X = RGB_888X_SK_COLORTYPE,
    Bgra8888 = BGRA_8888_SK_COLORTYPE, 
    Rgba1010102 = RGBA_1010102_SK_COLORTYPE, 
    Rgb101010X = RGB_101010X_SK_COLORTYPE,
    Gray8 = GRAY_8_SK_COLORTYPE, 
    RgbaF16 = RGBA_F16_SK_COLORTYPE
  
  SKAlphaType* = enum
    Opaque = OPAQUE_SK_ALPHATYPE, 
    Premul = PREMUL_SK_ALPHATYPE, 
    Unpremul = UNPREMUL_SK_ALPHATYPE
  
  SKStrokeCap* = enum
    ButtCap = BUTT_SK_STROKE_CAP, 
    RoundCap = ROUND_SK_STROKE_CAP, 
    SquareCap = SQUARE_SK_STROKE_CAP
  
  SKStrokeJoin* = enum
    MitelJoint = MITER_SK_STROKE_JOIN, 
    RoundJoint = ROUND_SK_STROKE_JOIN, 
    BevelJoint = BEVEL_SK_STROKE_JOIN
  
  SKClipOp* {.pure.} = enum
    Difference = DIFFERENCE_SK_CLIPOP
    Intersect = INTERSECT_SK_CLIPOP
  
  SKBlendMode* = enum
    Clear = CLEAR_SK_BLENDMODE
    Src = SRC_SK_BLENDMODE
    Dst = DST_SK_BLENDMODE
    SrcOver = SRCOVER_SK_BLENDMODE
    DstOver = DSTOVER_SK_BLENDMODE
    SrcIn = SRCIN_SK_BLENDMODE
    DstIn = DSTIN_SK_BLENDMODE
    SrcOut = SRCOUT_SK_BLENDMODE
    DstOut = DSTOUT_SK_BLENDMODE
    SrcATop = SRCATOP_SK_BLENDMODE
    DstATop = DSTATOP_SK_BLENDMODE
    Xor = XOR_SK_BLENDMODE
    Plus = PLUS_SK_BLENDMODE
    Modulate = MODULATE_SK_BLENDMODE
    Screen = SCREEN_SK_BLENDMODE
    Overlay = OVERLAY_SK_BLENDMODE
    Darken = DARKEN_SK_BLENDMODE
    Lighten = LIGHTEN_SK_BLENDMODE
    ColorDodge = COLORDODGE_SK_BLENDMODE
    ColorBurn = COLORBURN_SK_BLENDMODE
    HardLight = HARDLIGHT_SK_BLENDMODE
    SoftLight = SOFTLIGHT_SK_BLENDMODE
    Difference = DIFFERENCE_SK_BLENDMODE
    Exclusion = EXCLUSION_SK_BLENDMODE
    Multiply = MULTIPLY_SK_BLENDMODE
    Hue = HUE_SK_BLENDMODE
    Saturation = SATURATION_SK_BLENDMODE
    Color = COLOR_SK_BLENDMODE
    Luminosity LUMINOSITY_SK_BLENDMODE
  
const
  LastSeparableMode* = Multiply
  LastCoeffMode* = Screen
  LastMode* = Luminosity