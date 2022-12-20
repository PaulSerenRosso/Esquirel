using System;
using System.Collections;
using System.Collections.Generic;
using MiniMap;
using UnityEngine;

namespace MiniMap
{
public class MiniMapDynamicIcon : MiniMapIcon
{
    private void Update()
    {
        SetPositionInMiniMap();
    }
}
    
}
