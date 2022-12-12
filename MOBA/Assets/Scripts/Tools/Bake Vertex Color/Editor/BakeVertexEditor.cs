using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(BakeVertexColorMap))]
public class BakeVertexEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();
        BakeVertexColorMap bakeVertexColorMap = (BakeVertexColorMap)target;
        if (GUILayout.Button("Bake Vertex Color As PNG"))
        {
            bakeVertexColorMap.GetMesh();
            bakeVertexColorMap.BakeVertexColor();
        }
    }
}
