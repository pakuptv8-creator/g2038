Define.BIDDING_STATUS = {
  WAIT = "wait",
  BIDDING = "bidding",
  AUDIT = "audit",
  ELECTION = "election",
  SELECT = "select",
  FINALS = "finals",
  PUBLICITY = "publicity",
  NORMAL = "normal"
}
Define.BIDDING_STATUS_TIME_LINE = {
  [Define.BIDDING_STATUS.WAIT] = Define.BIDDING_STATUS.BIDDING,
  [Define.BIDDING_STATUS.BIDDING] = Define.BIDDING_STATUS.AUDIT,
  [Define.BIDDING_STATUS.AUDIT] = Define.BIDDING_STATUS.ELECTION,
  [Define.BIDDING_STATUS.ELECTION] = Define.BIDDING_STATUS.SELECT,
  [Define.BIDDING_STATUS.SELECT] = Define.BIDDING_STATUS.FINALS,
  [Define.BIDDING_STATUS.FINALS] = Define.BIDDING_STATUS.PUBLICITY,
  [Define.BIDDING_STATUS.PUBLICITY] = Define.BIDDING_STATUS.PUBLICITY,
  [Define.BIDDING_STATUS.NORMAL] = Define.BIDDING_STATUS.NORMAL
}
Define.BIDDING_STATUS_CONFIG = {
  wait = Define.BIDDING_STATUS.WAIT,
  bidding = Define.BIDDING_STATUS.BIDDING,
  audit = Define.BIDDING_STATUS.AUDIT,
  election = Define.BIDDING_STATUS.ELECTION,
  select = Define.BIDDING_STATUS.SELECT,
  finals = Define.BIDDING_STATUS.FINALS,
  publicity = Define.BIDDING_STATUS.PUBLICITY
}
Define.BIDDING_STATUS_NOTICE_DESC = {
  [Define.BIDDING_STATUS.WAIT] = "g2052.gui.bidding.status_wait",
  [Define.BIDDING_STATUS.BIDDING] = "g2052.gui.bidding.status_bidding",
  [Define.BIDDING_STATUS.AUDIT] = "g2052.gui.bidding.status_audit",
  [Define.BIDDING_STATUS.ELECTION] = "g2052.gui.bidding.status_election",
  [Define.BIDDING_STATUS.SELECT] = "g2052.gui.bidding.status_select",
  [Define.BIDDING_STATUS.FINALS] = "g2052.gui.bidding.status_finals",
  [Define.BIDDING_STATUS.PUBLICITY] = "g2052.gui.bidding.status_publicity",
  [Define.BIDDING_STATUS.NORMAL] = ""
}
