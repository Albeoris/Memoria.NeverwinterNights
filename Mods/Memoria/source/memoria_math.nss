// Shared geometry helpers for Memoria mods.

/// @brief Calculates the planar Euclidean distance between two vectors, ignoring their Z coordinates.
/// @param vLeft First point.
/// @param vRight Second point.
/// @return Two-dimensional distance between the points.
float MEMORIA_Distance2D(vector vLeft, vector vRight)
{
    float fX = vLeft.x - vRight.x;
    float fY = vLeft.y - vRight.y;
    return sqrt(fX * fX + fY * fY);
}

/// @brief Projects a point onto a planar line segment and clamps the projection to the segment endpoints.
/// @param vPoint Point to project.
/// @param vStart Segment start point and source of the returned Z coordinate.
/// @param vEnd Segment end point.
/// @return Closest point on the segment in the XY plane, or vStart for a degenerate segment.
vector MEMORIA_ClosestPointOnSegment2D(vector vPoint, vector vStart, vector vEnd)
{
    float fDeltaX = vEnd.x - vStart.x;
    float fDeltaY = vEnd.y - vStart.y;
    float fLengthSquared = fDeltaX * fDeltaX + fDeltaY * fDeltaY;
    if (fLengthSquared <= 0.0001f) return vStart;
    float fProjection = ((vPoint.x - vStart.x) * fDeltaX + (vPoint.y - vStart.y) * fDeltaY) / fLengthSquared;
    if (fProjection < 0.0f) fProjection = 0.0f;
    if (fProjection > 1.0f) fProjection = 1.0f;
    return Vector(vStart.x + fDeltaX * fProjection, vStart.y + fDeltaY * fProjection, vStart.z);
}

/// @brief Calculates the planar distance from a point to the closest point on a line segment.
/// @param vPoint Point whose distance is measured.
/// @param vStart Segment start point.
/// @param vEnd Segment end point.
/// @return Two-dimensional distance from vPoint to the segment.
float MEMORIA_DistanceToSegment2D(vector vPoint, vector vStart, vector vEnd)
{
    return MEMORIA_Distance2D(vPoint, MEMORIA_ClosestPointOnSegment2D(vPoint, vStart, vEnd));
}
