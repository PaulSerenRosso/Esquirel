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
        [SerializeField] private Sprite sprite;
        [SerializeField] private Vector2 iconSize;
         private Image image;
        
        private MiniMapManager miniMapManager;
        

        public void InitializeIcon(Sprite sprite)
        {
            miniMapManager = MiniMapManager.instance;
            image = Instantiate(miniMapManager.iconPrefab, miniMapManager.mapObject).GetComponent<Image>();

            image.sprite = sprite;
            SetPositionInMiniMap();
            SetSizeInMiniMap();
            SetSprite(sprite);
        }

        public void SetPositionInMiniMap()
        {
            if(image)
           image.rectTransform.anchoredPosition= miniMapManager.GetMiniMapPos(new Vector2(transform.position.x, transform.position.z));
     
        }

        public void SetActiveImage(bool value) => image.enabled = value;

        public void SetSprite(Sprite sprite)
        {
            this.sprite = sprite;
            image.sprite = sprite;
        }

        public void SetSizeInMiniMap()
        {
            Vector2 miniMapSize = miniMapManager.GetMiniMapSize();
            image.rectTransform.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, iconSize.x*miniMapSize.x);
            image.rectTransform.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, iconSize.y*miniMapSize.y);
        }

        

        public void GetSprite()
        {
        }
    }
}