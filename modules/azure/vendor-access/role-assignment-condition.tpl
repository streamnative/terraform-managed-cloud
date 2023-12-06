(
 (
  !(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})
 )
 OR 
 (
  @Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {e5e2a7ff-d759-4cd2-bb51-3152d37e2eb1, 4d97b98b-1d4f-4787-a291-c67834d212e7, befefa01-2a29-4197-83a8-272ff33ce314, acdd72a7-3385-48ef-bd42-f606fba81ae7, ba92f5b4-2d11-453d-a403-e96b0029c9fe, 0ab0b1a8-8aac-4efd-b8c2-3ee1fb270be8, 4abbcc35-e782-43d8-92c5-2d3f1bd2253f, ${role_definition_id}}
  AND
  @Request[Microsoft.Authorization/roleAssignments:PrincipalType] ForAnyOfAnyValues:StringEqualsIgnoreCase {'ServicePrincipal', 'Application', 'User'}
 )
)
AND
(
 (
  !(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})
 )
 OR 
 (
  @Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {e5e2a7ff-d759-4cd2-bb51-3152d37e2eb1, 4d97b98b-1d4f-4787-a291-c67834d212e7, befefa01-2a29-4197-83a8-272ff33ce314, acdd72a7-3385-48ef-bd42-f606fba81ae7, ba92f5b4-2d11-453d-a403-e96b0029c9fe, 0ab0b1a8-8aac-4efd-b8c2-3ee1fb270be8, 4abbcc35-e782-43d8-92c5-2d3f1bd2253f, ${role_definition_id}}
  AND
  @Resource[Microsoft.Authorization/roleAssignments:PrincipalType] ForAnyOfAnyValues:StringEqualsIgnoreCase {'ServicePrincipal', 'Application', 'User'}
 )
)