param name string
param tags object
param location string
@allowed([
  'Personal'
  'Pooled'
])
param hostPoolType string

param baseTime string = utcNow('u')

var tokenExpirationTime = dateTimeAdd(baseTime, 'P1D')

resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2021-03-09-preview' = {
  name: 'hp-${name}'
  location: location
  tags: tags
  properties: {
    hostPoolType: hostPoolType
    loadBalancerType: 'BreadthFirst'
    preferredAppGroupType: 'Desktop'
    maxSessionLimit: 999999
    startVMOnConnect: false
    validationEnvironment: false
    customRdpProperty: 'drivestoredirect:s:0;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:0;redirectprinters:i:0;devicestoredirect:s:0;redirectcomports:i:0;redirectsmartcards:i:1;usbdevicestoredirect:s:0;enablecredsspsupport:i:1;use multimon:i:1;targetisaadjoined:i:1'
    registrationInfo: {
      expirationTime: tokenExpirationTime
      registrationTokenOperation: 'Update'
    }
  }
}

output id string = hostPool.id
output name string = hostPool.name
output hostpoolToken string = reference(hostPool.id, '2021-01-14-preview').registrationInfo.token
