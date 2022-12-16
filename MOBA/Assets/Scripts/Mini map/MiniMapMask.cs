using System;
using UnityEngine;
using UnityEngine.Serialization;

[Serializable]
public class MiniMapMask
{
    public Color color;
    public RenderTexture inputTexture;
    public RenderTexture outputTexture;
    public Camera camera;
}