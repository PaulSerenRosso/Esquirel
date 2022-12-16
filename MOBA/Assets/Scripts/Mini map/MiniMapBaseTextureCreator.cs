using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace MiniMap
{
    public class MiniMapBaseTextureCreator : MonoBehaviour
    {
        [SerializeField] private List<MiniMapMask> miniMapMasks;

        [SerializeField]
        private RenderTexture baseMapTexture;

        public Material applierMaskColorMaterial;
        public Material mergerMaskMaterial;

       
        public void BakeBaseTexture()
        {
            EnabledMaskCameras();
            for (int i = 0; i < miniMapMasks.Count; i++)
            {
                BakeTextureWithColor(i);
            }
            BakeFirstIterationOfBaseTexture();
            MergeTextureWithColor();
            DisabledMaskCameras();
        }

        private void EnabledMaskCameras()
        {
            for (int i = 0; i < miniMapMasks.Count; i++)
            {
                miniMapMasks[i].camera.enabled = true;
            }
        }
        
        private void DisabledMaskCameras()
        {
            for (int i = 0; i < miniMapMasks.Count; i++)
            {
                miniMapMasks[i].camera.enabled = false;
            }
        }

        private void MergeTextureWithColor()
        {
            for (int i = 2; i < miniMapMasks.Count; i++)
            {
                mergerMaskMaterial.SetTexture("_SecondTex", miniMapMasks[i].outputTexture);
                mergerMaskMaterial.SetFloat("_ToleranceStep", 0.1f);

                Graphics.Blit(baseMapTexture, baseMapTexture, mergerMaskMaterial, 0);
                AssetDatabase.Refresh();
            }
        }

        private void BakeFirstIterationOfBaseTexture()
        {
            mergerMaskMaterial.SetTexture("_SecondTex", miniMapMasks[0].outputTexture);
            mergerMaskMaterial.SetFloat("_ToleranceStep", 0.1f);
            Graphics.Blit(miniMapMasks[1].outputTexture, baseMapTexture, mergerMaskMaterial, 0);
            AssetDatabase.Refresh();
        }

        void BakeTextureWithColor(int index)
        {
            applierMaskColorMaterial.SetColor("_MainColor", miniMapMasks[index].color);
            applierMaskColorMaterial.SetFloat("_ToleranceStep", 0.1f);
            Graphics.Blit(miniMapMasks[index].inputTexture, miniMapMasks[index].outputTexture, applierMaskColorMaterial, 0);
            AssetDatabase.Refresh();
        }
        
    }
}