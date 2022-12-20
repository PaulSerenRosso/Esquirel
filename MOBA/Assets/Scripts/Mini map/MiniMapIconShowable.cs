using System;
using System.Collections;
using System.Collections.Generic;
using Entities;
using MiniMap;
using UnityEngine;

namespace MiniMap
{
public class MiniMapIconShowable : MonoBehaviour
{
    private Entity entity;
    private MiniMapIcon miniMapIcon;
    private void Start()
    {
        entity = GetComponent<Entity>();
        miniMapIcon = GetComponent<MiniMapIcon>();
        entity.OnShowElementFeedback += Show;
        entity.OnHideElementFeedback += Hide;
    }

    void Hide() => miniMapIcon.SetActiveImage(false);
    void Show() => miniMapIcon.SetActiveImage(true);
}
}
