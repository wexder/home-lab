resource "truenas_dataset" "private_dataset" {
  pool             = "main_pool"
  name             = "private"
  compression      = "off"
  sync             = "standard"
  atime            = "off"
  copies           = 1
  deduplication    = "off"
  exec             = "on"
  snap_dir         = "hidden"
  readonly         = "off"
  record_size      = "128K"
  case_sensitivity = "sensitive"
  timeouts {}
}

resource "truenas_dataset" "downloads_dataset" {
  pool             = "main_pool"
  name             = "downloads"
  parent           = "private"
  atime            = "off"
  copies           = 1
  deduplication    = "off"
  exec             = "on"
  snap_dir         = "hidden"
  readonly         = "off"
  record_size      = "128K"
  case_sensitivity = "sensitive"
  timeouts {}

  depends_on = [
    truenas_dataset.private_dataset
  ]
}

resource "truenas_dataset" "k8s_dataset" {
  pool             = "main_pool"
  name             = "k8s"
  parent           = "private"
  atime            = "off"
  copies           = 1
  deduplication    = "off"
  exec             = "on"
  snap_dir         = "hidden"
  readonly         = "off"
  record_size      = "128K"
  case_sensitivity = "sensitive"
  timeouts {}

  depends_on = [
    truenas_dataset.private_dataset
  ]
}

resource "truenas_dataset" "media_dataset" {
  pool             = "main_pool"
  name             = "media"
  parent           = "private"
  atime            = "off"
  copies           = 1
  deduplication    = "off"
  exec             = "on"
  snap_dir         = "hidden"
  readonly         = "off"
  record_size      = "128K"
  case_sensitivity = "sensitive"
  timeouts {}

  depends_on = [
    truenas_dataset.private_dataset
  ]
}

resource "truenas_dataset" "ebooks_dataset" {
  pool             = "main_pool"
  name             = "ebooks"
  parent           = "private/media"
  atime            = "off"
  copies           = 1
  deduplication    = "off"
  exec             = "on"
  snap_dir         = "hidden"
  readonly         = "off"
  record_size      = "128K"
  case_sensitivity = "sensitive"
  timeouts {}

  depends_on = [
    truenas_dataset.media_dataset
  ]
}

resource "truenas_dataset" "movies_dataset" {
  pool             = "main_pool"
  name             = "movies"
  parent           = "private/media"
  atime            = "off"
  copies           = 1
  deduplication    = "off"
  exec             = "on"
  snap_dir         = "hidden"
  readonly         = "off"
  record_size      = "128K"
  case_sensitivity = "sensitive"
  timeouts {}

  depends_on = [
    truenas_dataset.media_dataset
  ]
}

resource "truenas_dataset" "shows_dataset" {
  pool             = "main_pool"
  name             = "shows"
  parent           = "private/media"
  atime            = "off"
  copies           = 1
  deduplication    = "off"
  exec             = "on"
  snap_dir         = "hidden"
  readonly         = "off"
  record_size      = "128K"
  case_sensitivity = "sensitive"
  timeouts {}

  depends_on = [
    truenas_dataset.media_dataset
  ]
}

resource "truenas_dataset" "travel_videos_dataset" {
  pool             = "main_pool"
  name             = "travel_videos"
  parent           = "private/media"
  atime            = "off"
  copies           = 1
  deduplication    = "off"
  exec             = "on"
  snap_dir         = "hidden"
  readonly         = "off"
  record_size      = "128K"
  case_sensitivity = "sensitive"
  timeouts {}

  depends_on = [
    truenas_dataset.media_dataset
  ]
}

resource "truenas_dataset" "photoprism_dataset" {
  pool             = "main_pool"
  name             = "photoprism"
  parent           = "private"
  atime            = "off"
  copies           = 1
  deduplication    = "off"
  exec             = "on"
  snap_dir         = "hidden"
  readonly         = "off"
  record_size      = "128K"
  case_sensitivity = "sensitive"
  timeouts {}

  depends_on = [
    truenas_dataset.private_dataset
  ]
}

resource "truenas_dataset" "home_dataset" {
  pool             = "main_pool"
  name             = "home"
  atime            = "off"
  copies           = 1
  deduplication    = "off"
  exec             = "on"
  snap_dir         = "hidden"
  readonly         = "off"
  record_size      = "128K"
  case_sensitivity = "sensitive"
  timeouts {}

  depends_on = [
    truenas_dataset.private_dataset
  ]
}
