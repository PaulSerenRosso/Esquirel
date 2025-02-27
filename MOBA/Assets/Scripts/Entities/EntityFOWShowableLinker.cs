using System.Collections;
using System.Collections.Generic;
using Entities;
using UnityEngine;
using UnityEngine.UI;

namespace Entities.FogOfWar
{
public class EntityFOWShowableLinker : MonoBehaviour
{

    public Renderer[] meshRenderers;
    public Graphic[] graphics;
 
    public void LinkEntity(Entity entity)
    {
        for (int i = 0; i < meshRenderers.Length; i++)
        {
            entity.meshRenderersToShow.Add(meshRenderers[i]);
            entity.meshRenderersToShowAlpha.Add(1);
        }

        for (int i = 0; i < graphics.Length; i++)
        {
            entity.graphicsToShow.Add(graphics[i]);
            entity.graphicsToShowAlpha.Add(1);
        }
    }
}
}
