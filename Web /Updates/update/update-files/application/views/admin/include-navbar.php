<?php $current_version = get_current_version(); ?>
<nav class="main-header navbar navbar-expand navbar-warning navbar-light navbar-orange">
    <!-- Left navbar links -->
    <ul class="navbar-nav">
        <li class="nav-item">
            <a class="nav-link" data-widget="pushmenu" href="#" role="button"><i class="fas fa-bars"></i></a>
        </li>
        <li class="nav-item my-auto">
            <span class="badge badge-success">v <?= (isset($current_version) && !empty($current_version)) ? $current_version : '1.0' ?></span>
        </li>
        <?php
        if (defined('ALLOW_MODIFICATION') && ALLOW_MODIFICATION == 0) {
        ?>
            <li class="nav-item my-auto ml-2">
                <span class="badge badge-danger">Demo mode</span>
            </li>
        <?php } ?>
    </ul>

    <!-- Right navbar links -->
    <ul class="navbar-nav ml-auto">
        <?php if (ALLOW_MODIFICATION == 0) { ?>
            <li class="nav-item">
                <a class="nav-link" data-widget="control-sidebar" data-slide="true" href="#" role="button">
                    <i class="fas fa-th-large"></i>
                </a>
            </li>
        <?php } ?>
        <?php
        $query = $this->db->query("select * from system_notification ORDER BY read_by ASC LIMIT 0,3");
        $notifications = $query->result_array();

        $count  = $this->db->query("select count(id) as total from system_notification where read_by = 0");
        $count_noti = $count->result_array(); ?>

        <a href="#" data-toggle="dropdown" class="nav-link notification-toggle nav-link-lg"><i class="fas fa-bell"></i><span class="badge badge-info navbar-badge"><?= $count_noti[0]['total'] ?></span></a>
        <div class="dropdown-menu dropdown-menu-lg dropdown-menu-right">
            <?php if (!empty($notifications)) { ?>
                <?php foreach ($notifications as $notification) { ?>
                    <?php $beep = (isset($notification['read_by']) && ($notification['read_by'] == 0)) ? '<span><i class="fa fa-certificate ml-3 text-orange text-sm"></i></span>' : ''; ?>
                    <a href="<?= base_url('admin/orders/edit_orders') . '?edit_id=' . $notification['type_id'] . '&noti_id=' . $notification['id']; ?>" class="dropdown-item">
                        <div class="media">
                            <div class="media-body">
                                <h3 class="dropdown-item-title"><?= $notification['title']; ?><?= $beep ?></h3>
                                <p class="text-sm"><?= word_limit($notification['message']); ?></p>
                                <?php $seconds_ago = (time() - strtotime($notification['date_sent']));
                                if ($seconds_ago >= 31536000) {
                                    $time =  intval($seconds_ago / 31536000) . " years ago";
                                } elseif ($seconds_ago >= 2419200) {
                                    $time =  intval($seconds_ago / 2419200) . " months ago";
                                } elseif ($seconds_ago >= 86400) {
                                    $time =  intval($seconds_ago / 86400) . " days ago";
                                } elseif ($seconds_ago >= 3600) {
                                    $time =  intval($seconds_ago / 3600) . " hours ago";
                                } elseif ($seconds_ago >= 60) {
                                    $time = intval($seconds_ago / 60) . " minutes ago";
                                } else {
                                    $time = "less than a minute ago";
                                } ?>
                                <p class="text-sm text-muted"><i class="far fa-clock mr-1"></i> <?= $time ?></p>
                            </div>
                        </div>
                    </a>
                    <div class="dropdown-divider"></div>
                <?php } ?>
            <?php } else { ?>
                <div class="dropdown-footer text-center">
                    <p>
                        <?= !empty($this->lang->line('label_no_unread_notifications_found')) ? $this->lang->line('label_no_unread_notifications_found') : 'No Unread Notifications Found!!'; ?>
                    </p>
                </div>
            <?php } ?>
            <a href="<?= base_url('admin/Notification_settings/manage_system_notifications') ?>" class="dropdown-item dropdown-footer">See All Messages</a>
        </div>
        <li class="nav-item dropdown">
            <a class="nav-link" data-toggle="dropdown" href="#">
                <i class="fa fa-user"></i>
            </a>
            <div class="dropdown-menu dropdown-menu-lg dropdown-menu-right">
                <?php if ($this->ion_auth->is_admin()) { ?>
                    <a href="#" class="dropdown-item">Welcome <b><?= ucfirst($this->ion_auth->user()->row()->username) ?> </b> ! </a>
                    <a href="<?= base_url('admin/home/profile') ?>" class="dropdown-item">
                        <i class="fas fa-user mr-2"></i> Profile
                    </a>
                    <a href="<?= base_url('admin/home/logout') ?>" class="dropdown-item">
                        <i class="fa fa-sign-out-alt mr-2"></i> Log Out
                    </a>
                <?php } else { ?>
                    <a href="#" class="dropdown-item">Welcome <b><?= ucfirst($this->ion_auth->user()->row()->username) ?> </b>! </a>
                    <a href="<?= base_url('delivery_boy/home/profile') ?>" class="dropdown-item"><i class="fas fa-user mr-2"></i> Profile </a>
                    <a href="<?= base_url('delivery_boy/home/logout') ?>" class="dropdown-item "><i class="fa fa-sign-out-alt mr-2"></i> Log Out </a>
                <?php } ?>
            </div>
        </li>
    </ul>
</nav>