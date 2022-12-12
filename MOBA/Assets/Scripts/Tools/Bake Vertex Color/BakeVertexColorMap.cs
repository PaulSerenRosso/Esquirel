using System;
using UnityEngine;
 
public class BakeVertexColorMap : MonoBehaviour
{
    Mesh SourceMesh;
    public Shader BakeVertexColorMapShader;
    public int Resolution = 2048;
    
    public void GetMesh()
    {
        SourceMesh = GetComponent<MeshFilter>().sharedMesh;
    }

    public void BakeVertexColor()
    {
        if (SourceMesh != null)
        {
            RenderTexture renderTexture = new RenderTexture(Resolution, Resolution, 0);
            renderTexture.Create();
            Material material = new Material(BakeVertexColorMapShader);
            RenderTexture currentTexture = RenderTexture.active;
            RenderTexture.active = renderTexture;
            GL.Clear(false, true, Color.black, 1.0f);
            material.SetPass(0);
            Graphics.DrawMeshNow(SourceMesh, Vector3.zero, Quaternion.identity);
            Texture2D texture = new Texture2D(Resolution, Resolution, TextureFormat.ARGB32, false);
            texture.ReadPixels( new Rect(0, 0, Resolution, Resolution), 0, 0);
            RenderTexture.active = currentTexture;
            byte[] bytes = texture.EncodeToPNG();
            System.IO.File.WriteAllBytes(System.IO.Path.Combine(Application.dataPath, "Map Data Vertex Color.png"), bytes);
            DestroyImmediate(material);
            DestroyImmediate(texture);
            renderTexture.Release();
        }
    }
}
