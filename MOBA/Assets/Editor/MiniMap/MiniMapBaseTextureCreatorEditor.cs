
using System;
using MiniMap;
using UnityEditor;
using UnityEngine;

namespace MiniMapEditor
{
    [CustomEditor(typeof(MiniMapBaseTextureCreator))]
public class MiniMapBaseTextureCreatorEditor : Editor
{
    private MiniMapBaseTextureCreator miniMapBaseTextureCreator;
    private void OnEnable()
    {
        miniMapBaseTextureCreator = (MiniMapBaseTextureCreator)target;
    }

    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        if (GUILayout.Button("Update Mini Map Base Texture"))
        {
            miniMapBaseTextureCreator.BakeBaseTexture();
        }
      
    }
}
}
