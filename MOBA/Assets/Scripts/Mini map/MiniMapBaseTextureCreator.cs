using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace MiniMap
{
    public class MiniMapBaseTextureCreator : MonoBehaviour
    {
        [SerializeField] private List<MiniMapMask> miniMapMasks;

        private Texture2D currentTextureMerged;
        [SerializeField] private Shader maskColorApplier;
        [SerializeField] private Shader masksMerger;


        public Material material;

        public void BakeBaseTexture()
        {
            for (int i = 0; i < miniMapMasks.Count; i++)
            {
                BakeTexture(i);
            }
        }

        void BakeTexture(int index)
        {
            material.SetColor("_MainColor", miniMapMasks[index].color);
            material.SetTexture("_BaseMap", miniMapMasks[index].inputTexture);
            material.SetFloat("ToleranceStep", 0.1f);
            material.SetPass(0);
            Graphics.Blit(miniMapMasks[index].inputTexture, miniMapMasks[index].outputTexture, material, 0);
            AssetDatabase.Refresh();
        }
    }
}