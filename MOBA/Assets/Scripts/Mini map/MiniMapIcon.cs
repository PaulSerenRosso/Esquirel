using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;
using UnityEngine.UI;

namespace MiniMap
{
    [Serializable]
    public class MiniMapIcon : MonoBehaviour
    {
        private RectTransform screenPosition;
        [SerializeField] private Sprite sprite;
        [SerializeField] private Vector2 iconSize;
         private Image image;

         [SerializeField] private bool setSize;
        private MiniMapManager miniMapManager;

        public void Start()
        {
            miniMapManager = MiniMapManager.instance;
            image = Instantiate(miniMapManager.iconPrefab, miniMapManager.mapObject).GetComponent<Image>();
            image.sprite = sprite;
            SetPositionInMiniMap();
            SetSizeInMiniMap();
        }

        public void SetPositionInMiniMap()
        {
           image.rectTransform.anchoredPosition= miniMapManager.GetMiniMapPos(new Vector2(transform.position.x, transform.position.z));
     
        }

        public void SetSizeInMiniMap()
        {
            image.rectTransform.sizeDelta = iconSize;
        
        }

        private void OnValidate()
        {
            if (setSize)
            {
                SetSizeInMiniMap();
            }
        }

        public void GetSprite()
        {
        }
    }
}