using System;
using System.Collections;
using System.Collections.Generic;
using MiniMap;
using UnityEngine;

namespace MiniMap
{
public class MiniMapDynamicIcon : MiniMapIcon
{
    protected override void Start()
    {
    }

    private void Update()
    {
        SetPositionInMiniMap();
    }
}
    
}
