using System.Collections;
using System.Collections.Generic;
using MiniMap;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(MiniMapManager))]
public class MiniMapManagerEditor : Editor
{
    private MiniMapManager miniMapManager;
    private void OnEnable()
    {
        miniMapManager = (MiniMapManager)target;
       
    }

    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        if (GUILayout.Button("Bake Static Icons"))
        {
            miniMapManager.BakeStaticIcons();
        }
        miniMapManager.UpdateMiniMapPos();
    }
}
