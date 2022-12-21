using System.Collections.Generic;
using UnityEngine;

namespace Entities.FogOfWar
{
  public class Bush : MonoBehaviour
  {
    
    
    public List<Entity> entitiesInside;
    public virtual bool IsNeededToViewEntityInsideBushForSeeShowableEntity(Entity viewableEntity,Entity showableEntity)
    {
      return true;
    }

    public virtual bool CheckBushMaskView(Entity viewableEntity)
    {
      if(viewableEntity.bushes.Contains(this)) return false;
      return true;
    }
  }
}
